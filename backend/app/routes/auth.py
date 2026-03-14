"""
Authentication Route Handlers
"""

import random
from datetime import datetime, timedelta
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.database import get_db
from app.models import User, OtpVerification
from app.schemas import (
    SendOtpRequest,
    SendOtpResponse,
    VerifyOtpRequest,
    SignupRequest,
    AuthResponse,
    UserResponse,
)
from app.utils.auth import create_access_token, create_refresh_token

router = APIRouter()


@router.post("/send-otp", response_model=SendOtpResponse)
async def send_otp(request: SendOtpRequest, db: Session = Depends(get_db)):
    """Send OTP to phone number."""
    phone = request.phone

    # Generate 6-digit OTP
    otp = str(random.randint(100000, 999999))

    # Store OTP in database
    expires_at = datetime.utcnow() + timedelta(minutes=10)
    otp_record = OtpVerification(
        phone=phone,
        otp=otp,
        expires_at=expires_at,
    )
    db.add(otp_record)
    db.commit()

    # In production, send OTP via SMS service
    # For development, just return success
    print(f"OTP for {phone}: {otp}")  # Debug only

    return SendOtpResponse(
        success=True,
        message="OTP sent successfully",
        otp_sent=True,
    )


@router.post("/verify-otp")
async def verify_otp(request: VerifyOtpRequest, db: Session = Depends(get_db)):
    """Verify OTP and check if user exists."""
    # Find valid OTP
    otp_record = db.query(OtpVerification).filter(
        OtpVerification.phone == request.phone,
        OtpVerification.otp == request.otp,
        OtpVerification.is_verified == False,
        OtpVerification.expires_at > datetime.utcnow(),
    ).order_by(OtpVerification.created_at.desc()).first()

    if not otp_record:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid or expired OTP",
        )

    # Mark OTP as verified
    otp_record.is_verified = True
    db.commit()

    # Check if user exists
    user = db.query(User).filter(User.phone == request.phone).first()

    if user:
        # User exists, return tokens
        access_token = create_access_token(data={"sub": str(user.id)})
        refresh_token = create_refresh_token(data={"sub": str(user.id)})

        return AuthResponse(
            access_token=access_token,
            refresh_token=refresh_token,
            user=UserResponse.model_validate(user),
        )
    else:
        # User doesn't exist, needs signup
        return {
            "success": True,
            "message": "OTP verified",
            "is_new_user": True,
            "phone": request.phone,
        }


@router.post("/signup", response_model=AuthResponse)
async def signup(request: SignupRequest, db: Session = Depends(get_db)):
    """Register new user after OTP verification."""
    # Check if user already exists
    existing_user = db.query(User).filter(User.phone == request.phone).first()
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="User already exists",
        )

    # Check if email is already taken
    if request.email:
        email_exists = db.query(User).filter(
            User.email == request.email).first()
        if email_exists:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Email already registered",
            )

    # Create new user
    user = User(
        phone=request.phone,
        name=request.name,
        email=request.email,
    )
    db.add(user)
    db.commit()
    db.refresh(user)

    # Generate tokens
    access_token = create_access_token(data={"sub": str(user.id)})
    refresh_token = create_refresh_token(data={"sub": str(user.id)})

    return AuthResponse(
        access_token=access_token,
        refresh_token=refresh_token,
        user=UserResponse.model_validate(user),
    )


@router.post("/refresh")
async def refresh_token(refresh_token: str, db: Session = Depends(get_db)):
    """Refresh access token."""
    from app.utils.auth import verify_token

    payload = verify_token(refresh_token)
    if not payload:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid refresh token",
        )

    user_id = payload.get("sub")
    user = db.query(User).filter(User.id == int(user_id)).first()

    if not user or not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User not found or inactive",
        )

    # Generate new access token
    access_token = create_access_token(data={"sub": str(user.id)})

    return {
        "access_token": access_token,
        "token_type": "bearer",
    }


@router.post("/logout")
async def logout():
    """Logout user (client-side token removal)."""
    return {"success": True, "message": "Logged out successfully"}
