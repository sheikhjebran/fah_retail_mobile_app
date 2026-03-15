"""
Admin route handlers.
"""

from datetime import datetime
from typing import Optional, List
from fastapi import APIRouter, Depends, HTTPException, Query, UploadFile, File
from sqlalchemy.orm import Session, joinedload
from sqlalchemy import func

from app.database import get_db
from app.models import User, Product, ProductImage, Category, Order, OrderItem, OrderStatusHistory, OrderStatus, UserRole
from app.schemas import ProductCreate, ProductUpdate, OrderStatusUpdate, DashboardStatsResponse
from app.utils.auth import get_admin_user
from app.utils.cloudinary import upload_image, upload_multiple_images, delete_image
from app.routes.products import product_to_response
from app.routes.orders import order_to_response

router = APIRouter()


@router.get("/dashboard")
async def get_dashboard_stats(
    admin: User = Depends(get_admin_user),
    db: Session = Depends(get_db),
):
    """Get admin dashboard statistics."""
    # Total revenue
    total_revenue = db.query(func.sum(Order.total_amount)).filter(
        Order.status == OrderStatus.delivered,
    ).scalar() or 0

    # Total orders
    total_orders = db.query(Order).count()

    # Total products
    total_products = db.query(Product).filter(
        Product.is_active == True).count()

    # Total customers (non-admin users)
    total_customers = db.query(User).filter(User.role != UserRole.admin).count()

    # Orders by status
    orders_by_status = {}
    for status in OrderStatus:
        count = db.query(Order).filter(Order.status == status).count()
        orders_by_status[status.value] = count

    # Revenue by month (last 6 months)
    revenue_by_month = {}
    for i in range(6):
        month = datetime.utcnow().month - i
        year = datetime.utcnow().year
        if month <= 0:
            month += 12
            year -= 1

        key = f"{year}-{month:02d}"
        revenue = db.query(func.sum(Order.total_amount)).filter(
            Order.status == OrderStatus.delivered,
            func.extract('month', Order.created_at) == month,
            func.extract('year', Order.created_at) == year,
        ).scalar() or 0
        revenue_by_month[key] = revenue

    # Recent orders
    recent_orders = db.query(Order).order_by(
        Order.created_at.desc()
    ).limit(10).all()

    return {
        "total_revenue": total_revenue,
        "total_orders": total_orders,
        "total_products": total_products,
        "total_customers": total_customers,
        "orders_by_status": orders_by_status,
        "revenue_by_month": revenue_by_month,
        "recent_orders": [order_to_response(o) for o in recent_orders],
    }


# ============ Product Management ============

@router.get("/products")
async def get_admin_products(
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    search: Optional[str] = None,
    include_inactive: bool = Query(False),
    admin: User = Depends(get_admin_user),
    db: Session = Depends(get_db),
):
    """Get all products for admin."""
    # Base query for counting
    base_query = db.query(Product)

    # By default, only show active products
    if not include_inactive:
        base_query = base_query.filter(Product.is_active == True)

    if search:
        base_query = base_query.filter(Product.name.ilike(f"%{search}%"))

    total = base_query.count()

    # Query with eager loading for fetching
    query = base_query.options(
        joinedload(Product.category),
        joinedload(Product.images),
    ).order_by(Product.created_at.desc())

    offset = (page - 1) * page_size
    products = query.offset(offset).limit(page_size).all()

    return {
        "items": [product_to_response(p) for p in products],
        "total": total,
        "page": page,
        "page_size": page_size,
        "total_pages": (total + page_size - 1) // page_size,
    }


@router.post("/products")
async def create_product(
    request: ProductCreate,
    admin: User = Depends(get_admin_user),
    db: Session = Depends(get_db),
):
    """Create new product."""
    product = Product(
        name=request.name,
        description=request.description,
        price=request.price,
        discount_price=request.discount_price,
        qty=request.qty,
        category_id=request.category_id,
        is_trending=request.is_trending,
    )
    db.add(product)
    db.commit()
    db.refresh(product)

    return product_to_response(product)


@router.put("/products/{product_id}")
async def update_product(
    product_id: int,
    request: ProductUpdate,
    admin: User = Depends(get_admin_user),
    db: Session = Depends(get_db),
):
    """Update product."""
    product = db.query(Product).filter(Product.id == product_id).first()

    if not product:
        raise HTTPException(status_code=404, detail="Product not found")

    if request.name is not None:
        product.name = request.name
    if request.description is not None:
        product.description = request.description
    if request.price is not None:
        product.price = request.price
    if request.discount_price is not None:
        product.discount_price = request.discount_price
    if request.qty is not None:
        product.qty = request.qty
    if request.category_id is not None:
        product.category_id = request.category_id
    if request.is_trending is not None:
        product.is_trending = request.is_trending
    if request.is_active is not None:
        product.is_active = request.is_active

    db.commit()
    db.refresh(product)

    return product_to_response(product)


@router.delete("/products/{product_id}")
async def delete_product(
    product_id: int,
    admin: User = Depends(get_admin_user),
    db: Session = Depends(get_db),
):
    """Delete product (soft delete)."""
    product = db.query(Product).filter(Product.id == product_id).first()

    if not product:
        raise HTTPException(status_code=404, detail="Product not found")

    product.is_active = False
    db.commit()

    return {"success": True, "message": "Product deleted"}


@router.post("/products/{product_id}/images")
async def add_product_image(
    product_id: int,
    image_url: str,
    is_primary: bool = False,
    admin: User = Depends(get_admin_user),
    db: Session = Depends(get_db),
):
    """Add image to product."""
    product = db.query(Product).filter(Product.id == product_id).first()

    if not product:
        raise HTTPException(status_code=404, detail="Product not found")

    # If primary, unset other primary images
    if is_primary:
        db.query(ProductImage).filter(
            ProductImage.product_id == product_id,
        ).update({"is_primary": False})

    # Get next sort order
    max_order = db.query(func.max(ProductImage.sort_order)).filter(
        ProductImage.product_id == product_id,
    ).scalar() or 0

    image = ProductImage(
        product_id=product_id,
        image_url=image_url,
        is_primary=is_primary,
        sort_order=max_order + 1,
    )
    db.add(image)
    db.commit()

    return {"success": True, "message": "Image added"}


@router.post("/products/{product_id}/upload-images")
async def upload_product_images(
    product_id: int,
    files: List[UploadFile] = File(...),
    admin: User = Depends(get_admin_user),
    db: Session = Depends(get_db),
):
    """Upload images to Cloudinary and add to product."""
    product = db.query(Product).filter(Product.id == product_id).first()

    if not product:
        raise HTTPException(status_code=404, detail="Product not found")

    # Upload images to Cloudinary
    uploaded_images = await upload_multiple_images(files, folder=f"products/{product_id}")

    # Get current max sort order
    max_order = db.query(func.max(ProductImage.sort_order)).filter(
        ProductImage.product_id == product_id,
    ).scalar() or 0

    # Check if product has any images (first one will be primary)
    has_images = db.query(ProductImage).filter(
        ProductImage.product_id == product_id,
    ).count() > 0

    created_images = []
    for i, img_data in enumerate(uploaded_images):
        is_primary = not has_images and i == 0
        
        image = ProductImage(
            product_id=product_id,
            image_url=img_data["url"],
            is_primary=is_primary,
            sort_order=max_order + i + 1,
        )
        db.add(image)
        db.flush()
        
        created_images.append({
            "id": image.id,
            "image_url": image.image_url,
            "is_primary": image.is_primary,
            "sort_order": image.sort_order,
        })
    
    db.commit()

    return {
        "success": True,
        "message": f"Uploaded {len(created_images)} images",
        "images": created_images,
    }


@router.delete("/products/{product_id}/images/{image_id}")
async def delete_product_image(
    product_id: int,
    image_id: int,
    admin: User = Depends(get_admin_user),
    db: Session = Depends(get_db),
):
    """Delete a product image."""
    image = db.query(ProductImage).filter(
        ProductImage.id == image_id,
        ProductImage.product_id == product_id,
    ).first()

    if not image:
        raise HTTPException(status_code=404, detail="Image not found")

    # Try to delete from Cloudinary (extract public_id from URL if possible)
    if "cloudinary.com" in image.image_url:
        try:
            # Extract public_id from URL
            parts = image.image_url.split("/upload/")
            if len(parts) == 2:
                public_id = parts[1].rsplit(".", 1)[0]  # Remove extension
                delete_image(public_id)
        except Exception:
            pass  # Continue even if Cloudinary delete fails

    db.delete(image)
    db.commit()

    return {"success": True, "message": "Image deleted"}


# ============ Order Management ============

@router.get("/orders")
async def get_admin_orders(
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    status: Optional[str] = None,
    admin: User = Depends(get_admin_user),
    db: Session = Depends(get_db),
):
    """Get all orders for admin."""
    query = db.query(Order)

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


@router.put("/orders/{order_id}/status")
async def update_order_status(
    order_id: int,
    request: OrderStatusUpdate,
    admin: User = Depends(get_admin_user),
    db: Session = Depends(get_db),
):
    """Update order status."""
    order = db.query(Order).filter(Order.id == order_id).first()

    if not order:
        raise HTTPException(status_code=404, detail="Order not found")

    try:
        new_status = OrderStatus(request.status)
    except ValueError:
        raise HTTPException(status_code=400, detail="Invalid status")

    order.status = new_status

    # Add status history
    status_history = OrderStatusHistory(
        order_id=order.id,
        status=new_status,
        note=request.note,
    )
    db.add(status_history)

    db.commit()

    return {"success": True, "message": "Order status updated"}
