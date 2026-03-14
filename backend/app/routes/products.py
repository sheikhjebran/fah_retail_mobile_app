"""
Product route handlers.
"""

from typing import Optional, List
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from sqlalchemy import or_

from app.database import get_db
from app.models import Product, ProductImage, Category
from app.schemas import ProductResponse, ProductCreate, ProductUpdate

router = APIRouter()


def product_to_response(product: Product) -> dict:
    """Convert Product model to response dict."""
    return {
        "id": product.id,
        "name": product.name,
        "description": product.description,
        "price": float(product.price) if product.price else 0,
        "discount_price": float(product.discount_price) if product.discount_price else None,
        "qty": product.qty,
        "category_id": product.category_id,
        "category_name": product.category.name if product.category else None,
        "is_trending": product.is_trending,
        "primary_image": product.primary_image,
        "shades": product.shades,
        "images": [
            {
                "id": img.id,
                "image_url": img.image_url,
                "is_primary": img.is_primary,
                "sort_order": img.sort_order,
            }
            for img in sorted(product.images, key=lambda x: x.sort_order)
        ] if product.images else [],
        "created_at": product.created_at.isoformat() if product.created_at else None,
    }


@router.get("")
async def get_products(
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    category_id: Optional[int] = None,
    search: Optional[str] = None,
    sort: Optional[str] = "newest",
    trending: Optional[bool] = None,
    discounted: Optional[bool] = None,
    db: Session = Depends(get_db),
):
    """Get products with filters and pagination."""
    query = db.query(Product).filter(Product.is_active == True)

    # Apply filters
    if category_id:
        query = query.filter(Product.category_id == category_id)

    if search:
        query = query.filter(
            or_(
                Product.name.ilike(f"%{search}%"),
                Product.description.ilike(f"%{search}%"),
            )
        )

    if trending:
        query = query.filter(Product.is_trending == True)

    if discounted:
        query = query.filter(Product.discount_price.isnot(None))

    # Apply sorting
    if sort == "newest":
        query = query.order_by(Product.created_at.desc())
    elif sort == "price_low":
        query = query.order_by(Product.price.asc())
    elif sort == "price_high":
        query = query.order_by(Product.price.desc())
    elif sort == "popular":
        query = query.order_by(Product.is_trending.desc(),
                               Product.created_at.desc())

    # Get total count
    total = query.count()

    # Apply pagination
    offset = (page - 1) * page_size
    products = query.offset(offset).limit(page_size).all()

    return {
        "items": [product_to_response(p) for p in products],
        "total": total,
        "page": page,
        "page_size": page_size,
        "total_pages": (total + page_size - 1) // page_size,
    }


@router.get("/trending")
async def get_trending_products(
    limit: int = Query(10, ge=1, le=50),
    db: Session = Depends(get_db),
):
    """Get trending products."""
    products = db.query(Product).filter(
        Product.is_active == True,
        Product.is_trending == True,
    ).order_by(Product.created_at.desc()).limit(limit).all()

    return [product_to_response(p) for p in products]


@router.get("/discounted")
async def get_discounted_products(
    limit: int = Query(10, ge=1, le=50),
    db: Session = Depends(get_db),
):
    """Get discounted products."""
    products = db.query(Product).filter(
        Product.is_active == True,
        Product.discount_price.isnot(None),
    ).order_by(Product.created_at.desc()).limit(limit).all()

    return [product_to_response(p) for p in products]


@router.get("/{product_id}")
async def get_product(product_id: int, db: Session = Depends(get_db)):
    """Get product by ID."""
    product = db.query(Product).filter(
        Product.id == product_id,
        Product.is_active == True,
    ).first()

    if not product:
        raise HTTPException(status_code=404, detail="Product not found")

    return product_to_response(product)


@router.get("/search/{query}")
async def search_products(
    query: str,
    limit: int = Query(20, ge=1, le=100),
    db: Session = Depends(get_db),
):
    """Search products by name or description."""
    products = db.query(Product).filter(
        Product.is_active == True,
        or_(
            Product.name.ilike(f"%{query}%"),
            Product.description.ilike(f"%{query}%"),
        )
    ).limit(limit).all()

    return [product_to_response(p) for p in products]
