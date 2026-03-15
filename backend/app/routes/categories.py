"""
Category route handlers.
"""

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.database import get_db
from app.models import Category
from app.schemas import CategoryResponse

router = APIRouter()


@router.get("")
async def get_categories(db: Session = Depends(get_db)):
    """Get all categories with subcategories."""
    # Get root categories (no parent)
    categories = db.query(Category).filter(
        Category.is_active == True,
        Category.parent_id.is_(None),
    ).all()

    def category_to_dict(cat):
        return {
            "id": cat.id,
            "name": cat.name,
            "image_url": cat.image_url,
            "parent_id": cat.parent_id,
            "subcategories": [category_to_dict(sub) for sub in cat.subcategories if sub.is_active],
        }

    return [category_to_dict(c) for c in categories]


@router.get("/{category_id}")
async def get_category(category_id: int, db: Session = Depends(get_db)):
    """Get category by ID."""
    category = db.query(Category).filter(
        Category.id == category_id,
        Category.is_active == True,
    ).first()

    if not category:
        from fastapi import HTTPException
        raise HTTPException(status_code=404, detail="Category not found")

    return {
        "id": category.id,
        "name": category.name,
        "image_url": category.image_url,
        "parent_id": category.parent_id,
        "subcategories": [
            {
                "id": sub.id,
                "name": sub.name,
                "image_url": sub.image_url,
            }
            for sub in category.subcategories if sub.is_active
        ],
    }
