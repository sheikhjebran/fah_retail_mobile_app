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
    from app.schemas import ProductResponse, CategoryResponse, ProductImageResponse
    
    cart_items = db.query(CartItem).filter(CartItem.user_id == user.id).all()

    items = []
    subtotal = 0

    for item in cart_items:
        product = item.product
        
        # Build product response object
        category_response = None
        if product.category:
            category_response = {
                "id": product.category.id,
                "name": product.category.name,
                "parent_id": product.category.parent_id,
                "image_url": product.category.image_url,
                "is_active": product.category.is_active,
                "subcategories": [],
            }
        
        # Build images list
        images = []
        if product.images:
            images = [
                {
                    "id": img.id,
                    "image_url": img.image_url,
                    "is_primary": img.is_primary,
                }
                for img in product.images
            ]
        
        # Build full product response
        product_response = {
            "id": product.id,
            "name": product.name,
            "description": product.description,
            "category_id": product.category_id,
            "price": float(product.price),
            "discount_price": float(product.discount_price) if product.discount_price else None,
            "qty": product.qty,
            "shades": product.shades,
            "is_trending": product.is_trending,
            "primary_image": product.primary_image,
            "is_active": product.is_active,
            "images": images,
            "category": category_response,
            "created_at": product.created_at.isoformat(),
        }
        
        price = float(product.discount_price or product.price)
        item_subtotal = float(price * item.quantity)
        subtotal += item_subtotal

        items.append({
            "id": item.id,
            "product_id": product.id,
            "product": product_response,
            "quantity": item.quantity,
            "created_at": item.created_at.isoformat(),
        })

    return {
        "items": items,
        "subtotal": subtotal,
        "total_items": sum(item.quantity for item in cart_items),
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

    if product.qty < request.quantity:
        raise HTTPException(status_code=400, detail="Insufficient stock")

    # Check if item already in cart
    existing_item = db.query(CartItem).filter(
        CartItem.user_id == current_user.id,
        CartItem.product_id == request.product_id,
    ).first()

    if existing_item:
        # Update quantity
        new_quantity = existing_item.quantity + request.quantity
        if new_quantity > product.qty:
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

    if request.quantity > cart_item.product.qty:
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

    return get_cart_response(current_user, db)
