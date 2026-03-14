"""
Pydantic Schemas for Request/Response Validation
"""

from datetime import datetime
from typing import Optional, List
from pydantic import BaseModel, EmailStr, Field


# ============ Base Schemas ============

class BaseResponse(BaseModel):
    """Base response schema."""
    success: bool = True
    message: str = "Success"


class PaginatedResponse(BaseModel):
    """Paginated response schema."""
    items: List
    total: int
    page: int
    page_size: int
    total_pages: int


# ============ Auth Schemas ============

class SendOtpRequest(BaseModel):
    """Send OTP request schema."""
    phone: str = Field(..., min_length=10, max_length=15)


class SendOtpResponse(BaseModel):
    """Send OTP response schema."""
    success: bool
    message: str
    otp_sent: bool


class VerifyOtpRequest(BaseModel):
    """Verify OTP request schema."""
    phone: str
    otp: str = Field(..., min_length=6, max_length=6)


class SignupRequest(BaseModel):
    """Signup request schema."""
    phone: str
    name: str = Field(..., min_length=2, max_length=100)
    email: Optional[EmailStr] = None


class AuthResponse(BaseModel):
    """Authentication response schema."""
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    user: "UserResponse"


# ============ User Schemas ============

class UserResponse(BaseModel):
    """User response schema."""
    id: int
    phone: str
    name: str
    email: Optional[str]
    is_admin: bool
    is_active: bool
    created_at: datetime

    class Config:
        from_attributes = True


class UserUpdate(BaseModel):
    """User update schema."""
    name: Optional[str] = None
    email: Optional[EmailStr] = None


# ============ Category Schemas ============

class CategoryResponse(BaseModel):
    """Category response schema."""
    id: int
    name: str
    slug: str
    image_url: Optional[str]
    parent_id: Optional[int]
    subcategories: List["CategoryResponse"] = []

    class Config:
        from_attributes = True


# ============ Product Schemas ============

class ProductImageResponse(BaseModel):
    """Product image response schema."""
    id: int
    image_url: str
    is_primary: bool
    sort_order: int

    class Config:
        from_attributes = True


class ProductResponse(BaseModel):
    """Product response schema."""
    id: int
    name: str
    description: Optional[str]
    price: int
    discount_price: Optional[int]
    stock: int
    category_id: Optional[int]
    category_name: Optional[str] = None
    is_trending: bool
    images: List[ProductImageResponse] = []
    created_at: datetime

    class Config:
        from_attributes = True


class ProductCreate(BaseModel):
    """Product create schema."""
    name: str = Field(..., min_length=2, max_length=200)
    description: Optional[str] = None
    price: int = Field(..., gt=0)
    discount_price: Optional[int] = None
    stock: int = Field(default=0, ge=0)
    category_id: Optional[int] = None
    is_trending: bool = False


class ProductUpdate(BaseModel):
    """Product update schema."""
    name: Optional[str] = None
    description: Optional[str] = None
    price: Optional[int] = None
    discount_price: Optional[int] = None
    stock: Optional[int] = None
    category_id: Optional[int] = None
    is_trending: Optional[bool] = None
    is_active: Optional[bool] = None


# ============ Cart Schemas ============

class CartItemResponse(BaseModel):
    """Cart item response schema."""
    id: int
    product_id: int
    product_name: str
    product_image: Optional[str]
    quantity: int
    price: int
    subtotal: int

    class Config:
        from_attributes = True


class CartResponse(BaseModel):
    """Cart response schema."""
    items: List[CartItemResponse]
    total_items: int
    total_amount: int


class AddToCartRequest(BaseModel):
    """Add to cart request schema."""
    product_id: int
    quantity: int = Field(default=1, ge=1)


class UpdateCartRequest(BaseModel):
    """Update cart item request schema."""
    quantity: int = Field(..., ge=1)


# ============ Address Schemas ============

class AddressResponse(BaseModel):
    """Address response schema."""
    id: int
    full_name: str
    phone: str
    address_line1: str
    address_line2: Optional[str]
    city: str
    state: str
    pincode: str
    label: str
    is_default: bool

    class Config:
        from_attributes = True


class AddressCreate(BaseModel):
    """Address create schema."""
    full_name: str = Field(..., min_length=2, max_length=100)
    phone: str = Field(..., min_length=10, max_length=15)
    address_line1: str = Field(..., min_length=5, max_length=200)
    address_line2: Optional[str] = None
    city: str = Field(..., min_length=2, max_length=100)
    state: str = Field(..., min_length=2, max_length=100)
    pincode: str = Field(..., min_length=6, max_length=10)
    label: str = Field(default="Home", max_length=50)
    is_default: bool = False


class AddressUpdate(BaseModel):
    """Address update schema."""
    full_name: Optional[str] = None
    phone: Optional[str] = None
    address_line1: Optional[str] = None
    address_line2: Optional[str] = None
    city: Optional[str] = None
    state: Optional[str] = None
    pincode: Optional[str] = None
    label: Optional[str] = None
    is_default: Optional[bool] = None


# ============ Order Schemas ============

class OrderItemResponse(BaseModel):
    """Order item response schema."""
    id: int
    product_id: int
    product_name: str
    product_image: Optional[str]
    quantity: int
    price: int
    subtotal: int

    class Config:
        from_attributes = True


class OrderStatusHistoryResponse(BaseModel):
    """Order status history response schema."""
    status: str
    note: Optional[str]
    timestamp: datetime

    class Config:
        from_attributes = True


class OrderResponse(BaseModel):
    """Order response schema."""
    id: int
    order_number: str
    user_id: int
    subtotal: int
    delivery_fee: int
    discount: int
    total_amount: int
    status: str
    payment_id: Optional[str]
    payment_status: str
    estimated_delivery: Optional[datetime]
    address: AddressResponse
    items: List[OrderItemResponse]
    status_history: List[OrderStatusHistoryResponse]
    created_at: datetime

    class Config:
        from_attributes = True


class PlaceOrderRequest(BaseModel):
    """Place order request schema."""
    address_id: int
    payment_id: Optional[str] = None


class OrderStatusUpdate(BaseModel):
    """Order status update schema."""
    status: str
    note: Optional[str] = None


# ============ Payment Schemas ============

class CreatePaymentOrderRequest(BaseModel):
    """Create payment order request schema."""
    amount: int = Field(..., gt=0)


class CreatePaymentOrderResponse(BaseModel):
    """Create payment order response schema."""
    id: str
    amount: int
    currency: str
    receipt: str


class VerifyPaymentRequest(BaseModel):
    """Verify payment request schema."""
    razorpay_payment_id: str
    razorpay_order_id: str
    razorpay_signature: str


# ============ Admin Schemas ============

class DashboardStatsResponse(BaseModel):
    """Dashboard stats response schema."""
    total_revenue: int
    total_orders: int
    total_products: int
    total_customers: int
    orders_by_status: dict
    revenue_by_month: dict
    recent_orders: List[OrderResponse]


# ============ Banner Schemas ============

class BannerResponse(BaseModel):
    """Banner response schema."""
    id: int
    title: Optional[str]
    image_url: str
    link: Optional[str]
    sort_order: int

    class Config:
        from_attributes = True


# Update forward references
AuthResponse.model_rebuild()
CategoryResponse.model_rebuild()
