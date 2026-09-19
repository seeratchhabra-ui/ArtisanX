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
    DateTime,
    Boolean
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

    # One user can have one artisan profile
    artisan_profile = relationship(
        "ArtisanProfile",
        back_populates="user",
        uselist=False
    )


# ============================================================
# 3. ARTISAN PROFILE MODEL
# ============================================================

class ArtisanProfile(Base):

    __tablename__ = "artisan_profiles"

    id = Column(
        Integer,
        primary_key=True,
        index=True
    )

    # Connect artisan profile to the existing User
    user_id = Column(
        Integer,
        ForeignKey("users.id"),
        unique=True,
        nullable=False
    )

    full_name = Column(
        String(150),
        nullable=False
    )

    bio = Column(
        Text,
        nullable=True
    )

    craft_type = Column(
        String(100),
        nullable=False
    )

    experience_years = Column(
        Integer,
        nullable=True
    )

    state = Column(
        String(100),
        nullable=True
    )

    district = Column(
        String(100),
        nullable=True
    )

    village = Column(
        String(100),
        nullable=True
    )

    profile_image = Column(
        String(500),
        nullable=True
    )

    # Relationship back to User
    user = relationship(
        "User",
        back_populates="artisan_profile"
    )


# ============================================================
# 4. PRODUCT MODEL
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

    media = relationship(
        "ProductMedia",
        back_populates="product",
        cascade="all, delete-orphan"
    )

    @property
    def seller_name(self) -> str:
        if self.seller:
            return self.seller.name
        return "Asha Devi"

    @property
    def seller_location(self) -> str:
        return self.state or "Jaipur, Rajasthan"

    @property
    def image_url(self) -> str:
        if self.media:
            for m in self.media:
                if m.is_primary:
                    return f"/uploads/{m.stored_filename}"
            if len(self.media) > 0:
                return f"/uploads/{self.media[0].stored_filename}"
        if self.category == "Baskets":
            return "https://images.unsplash.com/photo-1584589167171-541ce45f1eea?w=800&q=80"
        return "https://images.unsplash.com/photo-1610701596007-11502861dcfa?w=800&q=80"

    @property
    def tags(self) -> list:
        cat = self.category.lower() if self.category else "craft"
        return [f"#{cat}", "#handmade", "#kalasetu"]

    @property
    def material(self) -> str:
        if self.category == "Baskets":
            return "Moonj Grass"
        return "Terracotta Clay"

    @property
    def made_in(self) -> str:
        return f"{self.state or 'Rajasthan'}, India"

    @property
    def rating(self) -> float:
        return 4.9

    @property
    def review_count(self) -> int:
        return 18


# ============================================================
# 5. PRODUCT MEDIA
# ============================================================

class ProductMedia(Base):

    __tablename__ = "product_media"

    id = Column(
        Integer,
        primary_key=True,
        index=True
    )

    product_id = Column(
        Integer,
        ForeignKey("products.id"),
        nullable=False,
        index=True
    )

    # Original uploaded filename
    original_filename = Column(
        String(255),
        nullable=False
    )

    # UUID-based stored filename
    stored_filename = Column(
        String(255),
        nullable=False,
        unique=True
    )

    # Path used by the backend/storage system
    file_path = Column(
        String(500),
        nullable=False
    )

    # image / video
    media_type = Column(
        String(20),
        nullable=False
    )

    # image/jpeg, image/png, video/mp4, etc.
    mime_type = Column(
        String(100),
        nullable=False
    )

    # File size in bytes
    file_size = Column(
        Integer,
        nullable=False
    )

    # Order in which media should be displayed
    display_order = Column(
        Integer,
        default=0,
        nullable=False
    )

    # Main product image
    is_primary = Column(
        Boolean,
        default=False,
        nullable=False
    )

    # Reserved for future AI pipeline
    ai_status = Column(
        String(30),
        default="pending",
        nullable=False
    )

    # Future AI-generated/processed media
    processed_file_path = Column(
        String(500),
        nullable=True
    )

    created_at = Column(
        DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc),
        nullable=False
    )

    product = relationship(
        "Product",
        back_populates="media"
    )


# ============================================================
# 6. ORDER MODEL
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

    @property
    def product_name(self) -> str:
        if self.product:
            return self.product.name
        return "Indigo Glaze Serving Bowl"

    @property
    def artisan_name(self) -> str:
        if self.product and self.product.seller:
            return self.product.seller.name
        return "Asha Devi"

    @property
    def order_code(self) -> str:
        return f"#AX{1040 + (self.id or 1)}"