# ============================================================
# KALASETU - DATABASE MODELS
# ============================================================
#
# CURRENTLY ADDED:
# ✅ HeritageSite
# ✅ User
# ✅ Product
# ✅ Order
#
# NOT ADDED YET:
# ❌ Authentication
# ❌ Password hashing
# ❌ JWT
# ❌ OTP
# ❌ Role-based authorization
# ❌ AI/ML
# ❌ Gemini
# ❌ Bhashini
# ❌ Payments
#
# ============================================================

from datetime import datetime, timezone

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
# 1. HERITAGE SITE
# ============================================================
#
# This was already used to test:
#
# FastAPI → PostgreSQL
#
# We KEEP it.
#
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
#
# Represents a person using KalaSetu.
#
# IMPORTANT:
#
# This is ONLY the DATABASE MODEL right now.
#
# We are NOT implementing:
# ❌ Login
# ❌ Password
# ❌ JWT
# ❌ OTP
# ❌ Authentication
#
# Those will come later.
#
# ============================================================

class User(Base):

    __tablename__ = "users"

    # --------------------------------------------------------
    # Primary Key
    # --------------------------------------------------------

    id = Column(
        Integer,
        primary_key=True,
        index=True
    )

    # --------------------------------------------------------
    # User's name
    # --------------------------------------------------------

    name = Column(
        String(150),
        nullable=False
    )

    # --------------------------------------------------------
    # Email
    #
    # Stored as user information for now.
    # It is NOT being used for authentication yet.
    # --------------------------------------------------------

    email = Column(
        String(255),
        unique=True,
        nullable=False,
        index=True
    )

    # --------------------------------------------------------
    # Phone
    #
    # Stored for future application requirements.
    # OTP authentication is NOT implemented yet.
    # --------------------------------------------------------

    phone = Column(
        String(20),
        nullable=True
    )

    # --------------------------------------------------------
    # User type
    #
    # Example:
    # user
    # artisan
    # admin
    #
    # IMPORTANT:
    # This is ONLY stored as data.
    # It does NOT provide authorization yet.
    # --------------------------------------------------------

    role = Column(
        String(50),
        default="user",
        nullable=False
    )

    # --------------------------------------------------------
    # Relationship with products
    #
    # An artisan/user can have multiple products.
    # --------------------------------------------------------

    products = relationship(
        "Product",
        back_populates="seller"
    )

    # --------------------------------------------------------
    # Relationship with orders
    #
    # A user can have multiple orders.
    # --------------------------------------------------------

    orders = relationship(
        "Order",
        back_populates="user"
    )


# ============================================================
# 3. PRODUCT MODEL
# ============================================================
#
# Represents a craft/product that can be listed on KalaSetu.
#
# Examples:
#
# Handicrafts
# Handloom products
# Traditional artwork
# Cultural products
#
# ============================================================

class Product(Base):

    __tablename__ = "products"

    # --------------------------------------------------------
    # Primary Key
    # --------------------------------------------------------

    id = Column(
        Integer,
        primary_key=True,
        index=True
    )

    # --------------------------------------------------------
    # Product name
    # --------------------------------------------------------

    name = Column(
        String(200),
        nullable=False
    )

    # --------------------------------------------------------
    # Product description
    # --------------------------------------------------------

    description = Column(
        Text,
        nullable=True
    )

    # --------------------------------------------------------
    # Price
    # --------------------------------------------------------

    price = Column(
        Numeric(10, 2),
        nullable=False
    )

    # --------------------------------------------------------
    # Category
    #
    # Example:
    # Pottery
    # Handloom
    # Painting
    # Jewellery
    # Woodcraft
    #
    # --------------------------------------------------------

    category = Column(
        String(100),
        nullable=True
    )

    # --------------------------------------------------------
    # Stock quantity
    # --------------------------------------------------------

    stock = Column(
        Integer,
        default=0,
        nullable=False
    )

    # --------------------------------------------------------
    # State
    #
    # Useful for identifying the cultural region/origin.
    # --------------------------------------------------------

    state = Column(
        String(100),
        nullable=True
    )

    # --------------------------------------------------------
    # Seller / Artisan
    #
    # Links Product → User
    #
    # Foreign Key:
    # users.id
    #
    # --------------------------------------------------------

    seller_id = Column(
        Integer,
        ForeignKey("users.id"),
        nullable=False
    )

    # --------------------------------------------------------
    # Relationship back to User
    # --------------------------------------------------------

    seller = relationship(
        "User",
        back_populates="products"
    )

    # --------------------------------------------------------
    # Relationship with orders
    # --------------------------------------------------------

    orders = relationship(
        "Order",
        back_populates="product"
    )


# ============================================================
# 4. ORDER MODEL
# ============================================================
#
# Represents a purchase/order made by a user.
#
# Current simplified structure:
#
# User
#   ↓
# Order
#   ↓
# Product
#
# Later, when the marketplace becomes more advanced, we can
# introduce an OrderItem model for multiple products in one
# order.
#
# NOT ADDING THAT COMPLEXITY YET.
#
# ============================================================

class Order(Base):

    __tablename__ = "orders"

    # --------------------------------------------------------
    # Primary Key
    # --------------------------------------------------------

    id = Column(
        Integer,
        primary_key=True,
        index=True
    )

    # --------------------------------------------------------
    # User who placed the order
    # --------------------------------------------------------

    user_id = Column(
        Integer,
        ForeignKey("users.id"),
        nullable=False
    )

    # --------------------------------------------------------
    # Product being ordered
    # --------------------------------------------------------

    product_id = Column(
        Integer,
        ForeignKey("products.id"),
        nullable=False
    )

    # --------------------------------------------------------
    # Quantity ordered
    # --------------------------------------------------------

    quantity = Column(
        Integer,
        nullable=False
    )

    # --------------------------------------------------------
    # Total price
    #
    # This is calculated when the order is created.
    #
    # Example:
    #
    # Product price = ₹500
    # Quantity = 2
    #
    # Total = ₹1000
    #
    # --------------------------------------------------------

    total_price = Column(
        Numeric(10, 2),
        nullable=False
    )

    # --------------------------------------------------------
    # Order status
    #
    # Current basic statuses:
    #
    # pending
    # confirmed
    # shipped
    # delivered
    # cancelled
    #
    # No payment gateway is connected yet.
    #
    # --------------------------------------------------------

    status = Column(
        String(50),
        default="pending",
        nullable=False
    )

    # --------------------------------------------------------
    # Order creation time
    # --------------------------------------------------------

    created_at = Column(
        DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc),
        nullable=False
    )

    # --------------------------------------------------------
    # Relationships
    # --------------------------------------------------------

    user = relationship(
        "User",
        back_populates="orders"
    )

    product = relationship(
        "Product",
        back_populates="orders"
    )