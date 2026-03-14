"""
Payment route handlers.
"""

import razorpay
import hmac
import hashlib
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.config import settings
from app.database import get_db
from app.models import User
from app.schemas import CreatePaymentOrderRequest, CreatePaymentOrderResponse, VerifyPaymentRequest
from app.utils.auth import get_current_user

router = APIRouter()

# Initialize Razorpay client
razorpay_client = razorpay.Client(
    auth=(settings.RAZORPAY_KEY_ID, settings.RAZORPAY_KEY_SECRET)
)


@router.post("/create-order", response_model=CreatePaymentOrderResponse)
async def create_payment_order(
    request: CreatePaymentOrderRequest,
    current_user: User = Depends(get_current_user),
):
    """Create a Razorpay order."""
    try:
        order_data = {
            "amount": request.amount,  # Amount in paise
            "currency": "INR",
            "receipt": f"order_rcpt_{current_user.id}",
            "payment_capture": 1,  # Auto capture
        }

        order = razorpay_client.order.create(data=order_data)

        return CreatePaymentOrderResponse(
            id=order["id"],
            amount=order["amount"],
            currency=order["currency"],
            receipt=order["receipt"],
        )
    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f"Failed to create order: {str(e)}")


@router.post("/verify")
async def verify_payment(
    request: VerifyPaymentRequest,
    current_user: User = Depends(get_current_user),
):
    """Verify Razorpay payment signature."""
    try:
        # Create signature verification string
        msg = f"{request.razorpay_order_id}|{request.razorpay_payment_id}"

        # Generate signature
        generated_signature = hmac.new(
            settings.RAZORPAY_KEY_SECRET.encode(),
            msg.encode(),
            hashlib.sha256,
        ).hexdigest()

        # Verify signature
        if generated_signature == request.razorpay_signature:
            return {
                "success": True,
                "message": "Payment verified successfully",
                "payment_id": request.razorpay_payment_id,
            }
        else:
            raise HTTPException(
                status_code=400, detail="Payment verification failed")

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f"Verification error: {str(e)}")


@router.get("/key")
async def get_razorpay_key():
    """Get Razorpay public key."""
    return {"key": settings.RAZORPAY_KEY_ID}
