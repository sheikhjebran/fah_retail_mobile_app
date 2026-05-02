"""
Order route handlers.
"""

import secrets
from datetime import datetime, timedelta
from typing import Optional
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session

from app.database import get_db
from app.models import User, Order, OrderItem, OrderStatusHistory, CartItem, Address, OrderStatus, PaymentStatus
from app.schemas import OrderResponse, PlaceOrderRequest, OrderStatusUpdate
from app.utils.auth import get_current_user

router = APIRouter()


def generate_order_number() -> str:
    """Generate unique order number."""
    timestamp = datetime.utcnow().strftime("%Y%m%d")
    random_part = secrets.token_hex(3).upper()
    return f"ORD{timestamp}{random_part}"


def order_to_response(order: Order) -> dict:
    """Convert Order model to response dict."""
    return {
        "id": order.id,
        "order_number": order.order_number,
        "user_id": order.user_id,
        "total_amount": float(order.total_amount),
        "discount_amount": float(order.discount_amount) if order.discount_amount else 0,
        "delivery_fee": float(order.delivery_fee) if order.delivery_fee else 0,
        "payment_method": order.payment_method,
        "payment_status": order.payment_status.value if order.payment_status else "pending",
        "status": order.status.value,
        "delivery_address": {
            "id": order.address.id,
            "user_id": order.address.user_id,
            "name": order.address.name,
            "phone": order.address.phone,
            "building_number": order.address.building_number,
            "address": order.address.address,
            "landmark": order.address.landmark,
            "city": order.address.city,
            "state": order.address.state,
            "pincode": order.address.pincode,
            "alternate_phone": order.address.alternate_phone,
            "is_default": order.address.is_default,
        },
        "items": [
            {
                "id": item.id,
                "order_id": item.order_id,
                "product_id": item.product_id,
                "product": {
                    "id": item.product_id,
                    "name": item.product_name,
                    "description": "",
                    "category_id": 0,
                    "price": float(item.price),
                    "discount_price": float(item.discount_price) if item.discount_price else None,
                    "qty": 0,
                    "primary_image": item.product_image,
                    "is_trending": False,
                    "is_active": True,
                    "images": [],
                    "category": None,
                    "created_at": None,
                },
                "qty": item.qty,
                "price": float(item.price),
                "discount_price": float(item.discount_price) if item.discount_price else None,
            }
            for item in order.items
        ],
        "status_history": [
            {
                "id": history.id,
                "order_id": history.order_id,
                "status": history.status.value if hasattr(history.status, 'value') else history.status,
                "note": history.note,
                "timestamp": (history.timestamp or datetime.utcnow()).isoformat(),
            }
            for history in sorted(order.status_history, key=lambda x: x.timestamp or datetime.min, reverse=True)
        ],
        "created_at": order.created_at.isoformat() if order.created_at else None,
    }


@router.get("")
async def get_orders(
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    status: Optional[str] = None,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Get user's orders."""
    query = db.query(Order).filter(Order.user_id == current_user.id)

    if status:
        try:
            order_status = OrderStatus(status)
            query = query.filter(Order.status == order_status)
        except ValueError:
            pass

    query = query.order_by(Order.created_at.desc())

    total = query.count()
    offset = (page - 1) * page_size
    orders = query.offset(offset).limit(page_size).all()

    return {
        "items": [order_to_response(o) for o in orders],
        "total": total,
        "page": page,
        "page_size": page_size,
        "total_pages": (total + page_size - 1) // page_size,
    }


@router.get("/{order_id}")
async def get_order(
    order_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Get order by ID."""
    order = db.query(Order).filter(
        Order.id == order_id,
        Order.user_id == current_user.id,
    ).first()

    if not order:
        raise HTTPException(status_code=404, detail="Order not found")

    return order_to_response(order)


@router.post("")
async def place_order(
    request: PlaceOrderRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Place a new order from cart items."""
    # Validate address
    address = db.query(Address).filter(
        Address.id == request.address_id,
        Address.user_id == current_user.id,
    ).first()

    if not address:
        raise HTTPException(status_code=404, detail="Address not found")

    # Get cart items
    cart_items = db.query(CartItem).filter(
        CartItem.user_id == current_user.id).all()

    if not cart_items:
        raise HTTPException(status_code=400, detail="Cart is empty")

    # Calculate totals
    subtotal = 0
    order_items = []

    for cart_item in cart_items:
        product = cart_item.product

        if not product.is_active:
            raise HTTPException(
                status_code=400,
                detail=f"Product {product.name} is no longer available",
            )

        if product.qty < cart_item.quantity:
            raise HTTPException(
                status_code=400,
                detail=f"Insufficient stock for {product.name}",
            )

        price = product.discount_price or product.price
        item_subtotal = price * cart_item.quantity
        subtotal += item_subtotal

        order_items.append({
            "product_id": product.id,
            "product_name": product.name,
            "product_image": product.primary_image or (product.images[0].image_url if product.images else None),
            "qty": cart_item.quantity,
            "price": float(product.price),
            "discount_price": float(product.discount_price) if product.discount_price else None,
        })

        # Update stock
        product.qty -= cart_item.quantity

    # Calculate delivery fee (in rupees - free delivery over ₹499)
    delivery_fee = 0 if subtotal >= 499 else 49
    total_amount = subtotal + delivery_fee

    # Determine payment status based on payment method
    is_paid = request.razorpay_payment_id is not None

    # Create order
    order = Order(
        order_number=generate_order_number(),
        user_id=current_user.id,
        address_id=address.id,
        total_amount=total_amount,
        discount_amount=0,
        delivery_fee=delivery_fee,
        payment_method=request.payment_method,
        payment_status=PaymentStatus.paid if is_paid else PaymentStatus.pending,
        razorpay_order_id=request.razorpay_order_id,
        razorpay_payment_id=request.razorpay_payment_id,
        razorpay_signature=request.razorpay_signature,
        status=OrderStatus.order_placed,
    )
    db.add(order)
    db.flush()

    # Create order items
    for item_data in order_items:
        order_item = OrderItem(
            order_id=order.id,
            **item_data,
        )
        db.add(order_item)

    # Add status history
    status_history = OrderStatusHistory(
        order_id=order.id,
        status=order.status.value,
        note="Order placed successfully",
    )
    db.add(status_history)

    # Clear cart
    db.query(CartItem).filter(CartItem.user_id == current_user.id).delete()

    db.commit()
    db.refresh(order)

    return order_to_response(order)


@router.post("/{order_id}/cancel")
async def cancel_order(
    order_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Cancel an order."""
    order = db.query(Order).filter(
        Order.id == order_id,
        Order.user_id == current_user.id,
    ).first()

    if not order:
        raise HTTPException(status_code=404, detail="Order not found")

    if order.status in [OrderStatus.delivered, OrderStatus.cancelled]:
        raise HTTPException(status_code=400, detail="Cannot cancel this order")

    # Restore stock
    for item in order.items:
        item.product.qty += item.qty

    # Update order status
    order.status = OrderStatus.cancelled

    # Add status history
    status_history = OrderStatusHistory(
        order_id=order.id,
        status=OrderStatus.cancelled.value,
        note="Cancelled by customer",
    )
    db.add(status_history)

    db.commit()

    return {"success": True, "message": "Order cancelled successfully"}
