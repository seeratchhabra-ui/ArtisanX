# ============================================================
# KALASETU - API SCHEMAS
# ============================================================

from datetime import datetime
from decimal import Decimal

from pydantic import BaseModel, ConfigDict

from .models import UserRole


# ============================================================
# HERITAGE SITE
# ============================================================

class HeritageSiteCreate(BaseModel):

    name: str
    description: str | None = None
    location: str | None = None
    state: str | None = None
    category: str | None = None


class HeritageSiteResponse(BaseModel):

    id: int
    name: str
    description: str | None = None
    location: str | None = None
    state: str | None = None
    category: str | None = None

    model_config = ConfigDict(
        from_attributes=True
    )


# ============================================================
# USER
# ============================================================

class UserCreate(BaseModel):

    name: str
    email: str
    phone: str | None = None

    # Default role is CUSTOMER
    role: UserRole = UserRole.CUSTOMER


class UserUpdate(BaseModel):

    name: str | None = None
    email: str | None = None
    phone: str | None = None
    role: str | None = None


class UserResponse(BaseModel):

    id: int
    name: str
    email: str
    phone: str | None = None
    role: str

    model_config = ConfigDict(
        from_attributes=True
    )


# ============================================================
# ARTISAN PROFILE
# ============================================================

class ArtisanProfileCreate(BaseModel):

    full_name: str
    bio: str | None = None

    craft_type: str
    experience_years: int | None = None

    state: str | None = None
    district: str | None = None
    village: str | None = None

    profile_image: str | None = None


class ArtisanProfileResponse(BaseModel):

    id: int
    user_id: int

    full_name: str
    bio: str | None = None

    craft_type: str
    experience_years: int | None = None

    state: str | None = None
    district: str | None = None
    village: str | None = None

    profile_image: str | None = None

    model_config = ConfigDict(
        from_attributes=True
    )


# ============================================================
# PRODUCT
# ============================================================

class ProductCreate(BaseModel):

    name: str
    description: str | None = None
    price: Decimal
    category: str | None = None
    stock: int = 0
    state: str | None = None


class ProductUpdate(BaseModel):

    name: str | None = None
    description: str | None = None
    price: Decimal | None = None
    category: str | None = None
    stock: int | None = None
    state: str | None = None


class ProductResponse(BaseModel):

    id: int
    name: str
    description: str | None = None
    price: Decimal
    category: str | None = None
    stock: int
    state: str | None = None
    seller_id: int
    seller_name: str | None = None
    seller_location: str | None = None
    image_url: str | None = None
    tags: list[str] = []
    material: str | None = None
    made_in: str | None = None
    rating: float = 4.9
    review_count: int = 14

    model_config = ConfigDict(
        from_attributes=True
    )


# ============================================================
# ORDER
# ============================================================

class OrderCreate(BaseModel):

    product_id: int
    quantity: int
    user_id: int | None = None


class OrderUpdate(BaseModel):

    status: str


class OrderResponse(BaseModel):

    id: int
    user_id: int
    product_id: int
    quantity: int
    total_price: Decimal
    status: str
    created_at: datetime
    product_name: str | None = None
    artisan_name: str | None = None
    order_code: str | None = None

    model_config = ConfigDict(
        from_attributes=True
    )