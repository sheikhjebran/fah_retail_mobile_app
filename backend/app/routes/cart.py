"""
Cart route handlers.
"""

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.database import get_db
from app.models import User, CartItem, Product
from app.schemas import CartResponse, CartItemResponse, AddToCartRequest, UpdateCartRequest
from app.utils.auth import get_current_user

router = APIRouter()


def get_cart_response(user: User, db: Session) -> dict:
    """Build cart response for user."""
    cart_items = db.query(CartItem).filter(CartItem.user_id == user.id).all()

    items = []
    total_amount = 0

    for item in cart_items:
        product = item.product
        price = product.discount_price or product.price
        subtotal = price * item.quantity
        total_amount += subtotal

        items.append({
            "id": item.id,
            "product_id": product.id,
            "product_name": product.name,
            "product_image": product.images[0].image_url if product.images else None,
            "quantity": item.quantity,
            "price": price,
            "subtotal": subtotal,
        })

    return {
        "items": items,
        "total_items": sum(item.quantity for item in cart_items),
        "total_amount": total_amount,
    }


@router.get("", response_model=CartResponse)
async def get_cart(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Get current user's cart."""
    return get_cart_response(current_user, db)


@router.post("")
async def add_to_cart(
    request: AddToCartRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Add item to cart."""
    # Check if product exists and is active
    product = db.query(Product).filter(
        Product.id == request.product_id,
        Product.is_active == True,
    ).first()

    if not product:
        raise HTTPException(status_code=404, detail="Product not found")

    if product.stock < request.quantity:
        raise HTTPException(status_code=400, detail="Insufficient stock")

    # Check if item already in cart
    existing_item = db.query(CartItem).filter(
        CartItem.user_id == current_user.id,
        CartItem.product_id == request.product_id,
    ).first()

    if existing_item:
        # Update quantity
        new_quantity = existing_item.quantity + request.quantity
        if new_quantity > product.stock:
            raise HTTPException(status_code=400, detail="Insufficient stock")
        existing_item.quantity = new_quantity
    else:
        # Add new item
        cart_item = CartItem(
            user_id=current_user.id,
            product_id=request.product_id,
            quantity=request.quantity,
        )
        db.add(cart_item)

    db.commit()

    return get_cart_response(current_user, db)


@router.put("/{item_id}")
async def update_cart_item(
    item_id: int,
    request: UpdateCartRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Update cart item quantity."""
    cart_item = db.query(CartItem).filter(
        CartItem.id == item_id,
        CartItem.user_id == current_user.id,
    ).first()

    if not cart_item:
        raise HTTPException(status_code=404, detail="Cart item not found")

    if request.quantity > cart_item.product.stock:
        raise HTTPException(status_code=400, detail="Insufficient stock")

    cart_item.quantity = request.quantity
    db.commit()

    return get_cart_response(current_user, db)


@router.delete("/{item_id}")
async def remove_from_cart(
    item_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Remove item from cart."""
    cart_item = db.query(CartItem).filter(
        CartItem.id == item_id,
        CartItem.user_id == current_user.id,
    ).first()

    if not cart_item:
        raise HTTPException(status_code=404, detail="Cart item not found")

    db.delete(cart_item)
    db.commit()

    return get_cart_response(current_user, db)


@router.delete("")
async def clear_cart(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Clear all items from cart."""
    db.query(CartItem).filter(CartItem.user_id == current_user.id).delete()
    db.commit()

    return {"success": True, "message": "Cart cleared"}
