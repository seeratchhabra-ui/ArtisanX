# ============================================================
# KALASETU - DATABASE MODELS
# ============================================================

from datetime import datetime, timezone
from enum import Enum

from sqlalchemy import (
    Column,
    Integer,
    String,
    Text,
    ForeignKey,
    Numeric,
    DateTime
)

from sqlalchemy.orm import relationship

from .database import Base


# ============================================================
# USER ROLES
# ============================================================

class UserRole(str, Enum):
    CUSTOMER = "customer"
    ARTISAN = "artisan"
    ADMIN = "admin"


# ============================================================
# 1. HERITAGE SITE
# ============================================================

class HeritageSite(Base):

    __tablename__ = "heritage_sites"

    id = Column(
        Integer,
        primary_key=True,
        index=True
    )

    name = Column(
        String(200),
        nullable=False
    )

    description = Column(
        Text,
        nullable=True
    )

    location = Column(
        String(200),
        nullable=True
    )

    state = Column(
        String(100),
        nullable=True
    )

    category = Column(
        String(100),
        nullable=True
    )


# ============================================================
# 2. USER MODEL
# ============================================================

class User(Base):

    __tablename__ = "users"

    id = Column(
        Integer,
        primary_key=True,
        index=True
    )

    name = Column(
        String(150),
        nullable=False
    )

    email = Column(
        String(255),
        unique=True,
        nullable=False,
        index=True
    )

    phone = Column(
        String(20),
        nullable=True
    )

    role = Column(
        String(50),
        default=UserRole.CUSTOMER.value,
        nullable=False
    )

    products = relationship(
        "Product",
        back_populates="seller"
    )

    orders = relationship(
        "Order",
        back_populates="user"
    )


# ============================================================
# 3. PRODUCT MODEL
# ============================================================

class Product(Base):

    __tablename__ = "products"

    id = Column(
        Integer,
        primary_key=True,
        index=True
    )

    name = Column(
        String(200),
        nullable=False
    )

    description = Column(
        Text,
        nullable=True
    )

    price = Column(
        Numeric(10, 2),
        nullable=False
    )

    category = Column(
        String(100),
        nullable=True
    )

    stock = Column(
        Integer,
        default=0,
        nullable=False
    )

    state = Column(
        String(100),
        nullable=True
    )

    seller_id = Column(
        Integer,
        ForeignKey("users.id"),
        nullable=False
    )

    seller = relationship(
        "User",
        back_populates="products"
    )

    orders = relationship(
        "Order",
        back_populates="product"
    )


# ============================================================
# 4. ORDER MODEL
# ============================================================

class Order(Base):

    __tablename__ = "orders"

    id = Column(
        Integer,
        primary_key=True,
        index=True
    )

    user_id = Column(
        Integer,
        ForeignKey("users.id"),
        nullable=False
    )

    product_id = Column(
        Integer,
        ForeignKey("products.id"),
        nullable=False
    )

    quantity = Column(
        Integer,
        nullable=False
    )

    total_price = Column(
        Numeric(10, 2),
        nullable=False
    )

    status = Column(
        String(50),
        default="pending",
        nullable=False
    )

    created_at = Column(
        DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc),
        nullable=False
    )

    user = relationship(
        "User",
        back_populates="orders"
    )

    product = relationship(
        "Product",
        back_populates="orders"
    )