"""
Pydantic Schemas for FAH Retail App
"""

from datetime import datetime
from typing import Optional, List
from pydantic import BaseModel, Field
from enum import Enum


# =====================================================
# ENUMS
# =====================================================
class UserRole(str, Enum):
    user = "user"
    admin = "admin"


class PaymentStatus(str, Enum):
    pending = "pending"
    paid = "paid"
    failed = "failed"
    refunded = "refunded"


class OrderStatus(str, Enum):
    pending = "pending"
    order_placed = "order_placed"
    in_transit = "in_transit"
    delivered = "delivered"
    cancelled = "cancelled"


# =====================================================
# AUTH SCHEMAS
# =====================================================
class SendOTPRequest(BaseModel):
    phone: str = Field(..., min_length=10, max_length=15)


class SendOTPResponse(BaseModel):
    success: bool
    message: str
    otp: Optional[str] = None  # Only in dev mode


class VerifyOTPRequest(BaseModel):
    phone: str = Field(..., min_length=10, max_length=15)
    otp: str = Field(..., min_length=4, max_length=6)


class VerifyOTPResponse(BaseModel):
    success: bool
    message: str
    is_new_user: bool
    token: Optional[str] = None
    user: Optional["UserResponse"] = None


class SignupRequest(BaseModel):
    phone: str
    name: str
    email: Optional[str] = None
    address: Optional[str] = None
    city: Optional[str] = None
    state: Optional[str] = None
    pincode: Optional[str] = None


class LoginResponse(BaseModel):
    success: bool
    message: str
    token: str
    user: "UserResponse"


class AuthResponse(BaseModel):
    access_token: str
    refresh_token: str
    user: "UserResponse"
    token_type: str = "bearer"


# =====================================================
# USER SCHEMAS
# =====================================================
class UserBase(BaseModel):
    name: str
    phone: str
    email: Optional[str] = None
    address: Optional[str] = None
    city: Optional[str] = None
    state: Optional[str] = None
    pincode: Optional[str] = None


class UserCreate(UserBase):
    pass


class UserUpdate(BaseModel):
    name: Optional[str] = None
    email: Optional[str] = None
    address: Optional[str] = None
    city: Optional[str] = None
    state: Optional[str] = None
    pincode: Optional[str] = None


class UserResponse(UserBase):
    id: int
    role: UserRole
    is_active: bool
    created_at: datetime

    class Config:
        from_attributes = True


# =====================================================
# CATEGORY SCHEMAS
# =====================================================
class CategoryBase(BaseModel):
    name: str
    parent_id: Optional[int] = None
    image_url: Optional[str] = None
    sort_order: int = 0


class CategoryCreate(CategoryBase):
    pass


class CategoryResponse(CategoryBase):
    id: int
    is_active: bool
    subcategories: List["CategoryResponse"] = []

    class Config:
        from_attributes = True


# =====================================================
# PRODUCT SCHEMAS
# =====================================================
class ProductImageResponse(BaseModel):
    id: int
    image_url: str
    is_primary: bool

    class Config:
        from_attributes = True


class ProductBase(BaseModel):
    name: str
    description: Optional[str] = None
    category_id: int
    price: float
    discount_price: Optional[float] = None
    qty: int = 0
    shades: Optional[List[str]] = None
    is_trending: bool = False


class ProductCreate(ProductBase):
    pass


class ProductUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    category_id: Optional[int] = None
    price: Optional[float] = None
    discount_price: Optional[float] = None
    qty: Optional[int] = None
    shades: Optional[List[str]] = None
    is_trending: Optional[bool] = None


class ProductResponse(ProductBase):
    id: int
    primary_image: Optional[str] = None
    is_active: bool
    images: List[ProductImageResponse] = []
    category: Optional[CategoryResponse] = None
    created_at: datetime

    class Config:
        from_attributes = True


class ProductListResponse(BaseModel):
    items: List[ProductResponse]
    total: int
    page: int
    page_size: int
    has_next: bool


# =====================================================
# ADDRESS SCHEMAS
# =====================================================
class AddressBase(BaseModel):
    name: str
    phone: str
    address: str
    city: str
    state: str
    pincode: str
    is_default: bool = False


class AddressCreate(AddressBase):
    pass


class AddressUpdate(BaseModel):
    name: Optional[str] = None
    phone: Optional[str] = None
    address: Optional[str] = None
    city: Optional[str] = None
    state: Optional[str] = None
    pincode: Optional[str] = None
    is_default: Optional[bool] = None


class AddressResponse(AddressBase):
    id: int
    user_id: int
    created_at: datetime

    class Config:
        from_attributes = True


# =====================================================
# CART SCHEMAS
# =====================================================
class AddToCartRequest(BaseModel):
    product_id: int
    quantity: int = 1


class UpdateCartRequest(BaseModel):
    quantity: int


class CartItemResponse(BaseModel):
    id: int
    product_id: int
    quantity: int
    product: ProductResponse
    created_at: datetime

    class Config:
        from_attributes = True


class CartResponse(BaseModel):
    items: List[CartItemResponse]
    subtotal: float
    total_items: int


# =====================================================
# ORDER SCHEMAS
# =====================================================
class OrderItemResponse(BaseModel):
    id: int
    product_id: int
    product_name: str
    product_image: Optional[str] = None
    qty: int
    price: float
    discount_price: Optional[float] = None

    class Config:
        from_attributes = True


class OrderStatusHistoryResponse(BaseModel):
    id: int
    status: str
    note: Optional[str] = None
    timestamp: datetime

    class Config:
        from_attributes = True


class OrderResponse(BaseModel):
    id: int
    user_id: int
    order_number: str
    total_amount: float
    discount_amount: float
    delivery_fee: float
    payment_method: str
    payment_status: PaymentStatus
    status: OrderStatus
    items: List[OrderItemResponse] = []
    delivery_address: Optional[AddressResponse] = None
    status_history: List[OrderStatusHistoryResponse] = []
    created_at: datetime

    class Config:
        from_attributes = True


class PlaceOrderRequest(BaseModel):
    address_id: int
    payment_method: str
    razorpay_order_id: Optional[str] = None
    razorpay_payment_id: Optional[str] = None
    razorpay_signature: Optional[str] = None


class OrderListResponse(BaseModel):
    items: List[OrderResponse]
    total: int
    page: int
    page_size: int
    has_next: bool


class UpdateOrderStatusRequest(BaseModel):
    status: OrderStatus
    note: Optional[str] = None


# =====================================================
# PAYMENT SCHEMAS
# =====================================================
class CreatePaymentOrderRequest(BaseModel):
    amount: int  # Amount in paise
    currency: str = "INR"


class PaymentOrderResponse(BaseModel):
    id: str
    amount: int
    currency: str
    receipt: str


class VerifyPaymentRequest(BaseModel):
    razorpay_order_id: str
    razorpay_payment_id: str
    razorpay_signature: str


# =====================================================
# BANNER SCHEMAS
# =====================================================
class BannerResponse(BaseModel):
    id: int
    title: Optional[str] = None
    image_url: str
    link: Optional[str] = None
    sort_order: int

    class Config:
        from_attributes = True


# =====================================================
# DASHBOARD SCHEMAS
# =====================================================
class DashboardStats(BaseModel):
    today_sales: float
    total_orders: int
    pending_orders: int
    delivered_orders: int
    cancelled_orders: int
    total_products: int
    low_stock_products: int
    top_selling_products: List[dict] = []
    weekly_sales: List[dict] = []
    category_sales: List[dict] = []


# =====================================================
# GENERIC RESPONSE
# =====================================================
class MessageResponse(BaseModel):
    success: bool
    message: str


# Update forward refs
CategoryResponse.model_rebuild()
VerifyOTPResponse.model_rebuild()
