"""
Banner route handlers.
"""

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.database import get_db
from app.models import Banner

router = APIRouter()


@router.get("")
async def get_banners(db: Session = Depends(get_db)):
    """Get active banners for home screen."""
    banners = db.query(Banner).filter(
        Banner.is_active == True,
    ).order_by(Banner.sort_order.asc()).all()

    return [
        {
            "id": banner.id,
            "title": banner.title,
            "image_url": banner.image_url,
            "link": banner.link,
            "sort_order": banner.sort_order,
        }
        for banner in banners
    ]
