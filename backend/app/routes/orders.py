"""
Order route handlers.
"""

import secrets
from datetime import datetime, timedelta
from typing import Optional
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session

from app.database import get_db
from app.models import User, Order, OrderItem, OrderStatusHistory, CartItem, Address, OrderStatus
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
        "subtotal": order.subtotal,
        "delivery_fee": order.delivery_fee,
        "discount": order.discount,
        "total_amount": order.total_amount,
        "status": order.status.value,
        "payment_id": order.payment_id,
        "payment_status": order.payment_status,
        "estimated_delivery": order.estimated_delivery,
        "address": {
            "id": order.address.id,
            "full_name": order.address.full_name,
            "phone": order.address.phone,
            "address_line1": order.address.address_line1,
            "address_line2": order.address.address_line2,
            "city": order.address.city,
            "state": order.address.state,
            "pincode": order.address.pincode,
            "label": order.address.label,
            "is_default": order.address.is_default,
        },
        "items": [
            {
                "id": item.id,
                "product_id": item.product_id,
                "product_name": item.product_name,
                "product_image": item.product_image,
                "quantity": item.quantity,
                "price": item.price,
                "subtotal": item.subtotal,
            }
            for item in order.items
        ],
        "status_history": [
            {
                "status": history.status.value,
                "note": history.note,
                "timestamp": history.timestamp,
            }
            for history in sorted(order.status_history, key=lambda x: x.timestamp, reverse=True)
        ],
        "created_at": order.created_at,
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

        if product.stock < cart_item.quantity:
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
            "product_image": product.images[0].image_url if product.images else None,
            "quantity": cart_item.quantity,
            "price": price,
            "subtotal": item_subtotal,
        })

        # Update stock
        product.stock -= cart_item.quantity

    # Calculate delivery fee
    delivery_fee = 0 if subtotal >= 49900 else 4900  # Free delivery over ₹499
    total_amount = subtotal + delivery_fee

    # Create order
    order = Order(
        order_number=generate_order_number(),
        user_id=current_user.id,
        address_id=address.id,
        subtotal=subtotal,
        delivery_fee=delivery_fee,
        discount=0,
        total_amount=total_amount,
        status=OrderStatus.order_placed if request.payment_id else OrderStatus.pending,
        payment_id=request.payment_id,
        payment_status="paid" if request.payment_id else "pending",
        estimated_delivery=datetime.utcnow() + timedelta(days=5),
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
        status=order.status,
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
        item.product.stock += item.quantity

    # Update order status
    order.status = OrderStatus.cancelled

    # Add status history
    status_history = OrderStatusHistory(
        order_id=order.id,
        status=OrderStatus.cancelled,
        note="Cancelled by customer",
    )
    db.add(status_history)

    db.commit()

    return {"success": True, "message": "Order cancelled successfully"}
