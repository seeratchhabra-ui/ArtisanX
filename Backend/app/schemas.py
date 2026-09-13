# ============================================================
# KALASETU - API SCHEMAS
# ============================================================

from datetime import datetime
from decimal import Decimal
from enum import Enum

from pydantic import BaseModel, ConfigDict


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
# USER ROLES
# ============================================================

class RegistrationRole(str, Enum):
    CUSTOMER = "customer"
    ARTISAN = "artisan"


# ============================================================
# USER
# ============================================================

class UserCreate(BaseModel):

    name: str
    email: str
    phone: str | None = None
    role: RegistrationRole = RegistrationRole.CUSTOMER


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
# PRODUCT
# ============================================================

class ProductCreate(BaseModel):

    name: str
    description: str | None = None
    price: Decimal
    category: str | None = None
    stock: int = 0
    state: str | None = None
    seller_id: int


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

    model_config = ConfigDict(
        from_attributes=True
    )


# ============================================================
# ORDER
# ============================================================

class OrderCreate(BaseModel):

    user_id: int
    product_id: int
    quantity: int


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

    model_config = ConfigDict(
        from_attributes=True
    )