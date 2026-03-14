"""
Models Package - Exports all SQLAlchemy models
"""

from app.models.models import (
    User,
    UserRole,
    OTP,
    Category,
    Product,
    ProductImage,
    Address,
    CartItem,
    Order,
    OrderItem,
    OrderStatus,
    OrderStatusHistory,
    PaymentStatus,
    Banner,
)

# Alias for backwards compatibility
OtpVerification = OTP

__all__ = [
    "User",
    "UserRole",
    "OTP",
    "OtpVerification",
    "Category",
    "Product",
    "ProductImage",
    "Address",
    "CartItem",
    "Order",
    "OrderItem",
    "OrderStatus",
    "OrderStatusHistory",
    "PaymentStatus",
    "Banner",
]
