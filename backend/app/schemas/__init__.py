"""
Schemas Package - Exports all Pydantic schemas
"""

from app.schemas.schemas import (
    # Enums
    UserRole,
    PaymentStatus,
    OrderStatus,

    # Auth
    SendOTPRequest,
    SendOTPResponse,
    VerifyOTPRequest,
    VerifyOTPResponse,
    SignupRequest,
    LoginResponse,
    AuthResponse,

    # User
    UserBase,
    UserCreate,
    UserUpdate,
    UserResponse,

    # Category
    CategoryBase,
    CategoryCreate,
    CategoryResponse,

    # Product
    ProductImageResponse,
    ProductBase,
    ProductCreate,
    ProductUpdate,
    ProductResponse,
    ProductListResponse,

    # Address
    AddressBase,
    AddressCreate,
    AddressUpdate,
    AddressResponse,

    # Cart
    AddToCartRequest,
    UpdateCartRequest,
    CartItemResponse,
    CartResponse,

    # Order
    OrderItemResponse,
    OrderStatusHistoryResponse,
    OrderResponse,
    PlaceOrderRequest,
    OrderListResponse,
    UpdateOrderStatusRequest,

    # Payment
    CreatePaymentOrderRequest,
    PaymentOrderResponse,
    VerifyPaymentRequest,

    # Banner
    BannerBase,
    BannerCreate,
    BannerUpdate,
    BannerResponse,

    # Dashboard
    DashboardStats,

    # Generic
    MessageResponse,
)

# Backwards compatibility aliases
SendOtpRequest = SendOTPRequest
SendOtpResponse = SendOTPResponse
VerifyOtpRequest = VerifyOTPRequest
OrderStatusUpdate = UpdateOrderStatusRequest
CreatePaymentOrderResponse = PaymentOrderResponse
DashboardStatsResponse = DashboardStats

__all__ = [
    "UserRole",
    "PaymentStatus",
    "OrderStatus",
    "SendOTPRequest",
    "SendOTPResponse",
    "VerifyOTPRequest",
    "VerifyOTPResponse",
    "SignupRequest",
    "LoginResponse",
    "UserBase",
    "UserCreate",
    "UserUpdate",
    "UserResponse",
    "CategoryBase",
    "CategoryCreate",
    "CategoryResponse",
    "ProductImageResponse",
    "ProductBase",
    "ProductCreate",
    "ProductUpdate",
    "ProductResponse",
    "ProductListResponse",
    "AddressBase",
    "AddressCreate",
    "AddressUpdate",
    "AddressResponse",
    "AddToCartRequest",
    "UpdateCartRequest",
    "CartItemResponse",
    "CartResponse",
    "OrderItemResponse",
    "OrderStatusHistoryResponse",
    "OrderResponse",
    "PlaceOrderRequest",
    "OrderListResponse",
    "UpdateOrderStatusRequest",
    "CreatePaymentOrderRequest",
    "PaymentOrderResponse",
    "VerifyPaymentRequest",
    "BannerResponse",
    "DashboardStats",
    "MessageResponse",
    # Aliases
    "SendOtpRequest",
    "SendOtpResponse",
    "VerifyOtpRequest",
    "AuthResponse",
]
