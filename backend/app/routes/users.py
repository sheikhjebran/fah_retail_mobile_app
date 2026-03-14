"""
User route handlers.
"""

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.database import get_db
from app.models import User
from app.schemas import UserResponse, UserUpdate
from app.utils.auth import get_current_user

router = APIRouter()


@router.get("/me", response_model=UserResponse)
async def get_profile(current_user: User = Depends(get_current_user)):
    """Get current user profile."""
    return UserResponse.model_validate(current_user)


@router.put("/me", response_model=UserResponse)
async def update_profile(
    request: UserUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Update current user profile."""
    if request.name:
        current_user.name = request.name

    if request.email:
        # Check if email is taken by another user
        existing = db.query(User).filter(
            User.email == request.email,
            User.id != current_user.id,
        ).first()
        if existing:
            raise HTTPException(
                status_code=400, detail="Email already registered")
        current_user.email = request.email

    db.commit()
    db.refresh(current_user)

    return UserResponse.model_validate(current_user)
