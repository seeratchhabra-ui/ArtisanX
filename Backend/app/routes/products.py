# ============================================================
# KALASETU - PRODUCT CRUD
# ============================================================

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from ..database import get_db
from ..models import Product, User
from ..schemas import (
    ProductCreate,
    ProductUpdate,
    ProductResponse
)
from ..auth import get_current_user


router = APIRouter(
    prefix="/api/products",
    tags=["Products"]
)


# ============================================================
# CREATE PRODUCT
# ============================================================

@router.post(
    "/",
    response_model=ProductResponse
)
def create_product(
    product: ProductCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):

    # Only authenticated users can create products

    # Check whether seller/user exists
    seller = db.query(User).filter(
        User.id == product.seller_id
    ).first()

    if not seller:
        raise HTTPException(
            status_code=404,
            detail="Seller/User not found"
        )

    # Make sure the logged-in user is the seller
    if seller.id != current_user.id:
        raise HTTPException(
            status_code=403,
            detail="You can only create products for your own account"
        )

    new_product = Product(
        name=product.name,
        description=product.description,
        price=product.price,
        category=product.category,
        stock=product.stock,
        state=product.state,
        seller_id=current_user.id
    )

    db.add(new_product)
    db.commit()
    db.refresh(new_product)

    return new_product


# ============================================================
# GET ALL PRODUCTS
# ============================================================

@router.get(
    "/",
    response_model=list[ProductResponse]
)
def get_products(
    db: Session = Depends(get_db)
):

    # Public endpoint
    return db.query(Product).all()


# ============================================================
# GET ONE PRODUCT
# ============================================================

@router.get(
    "/{product_id}",
    response_model=ProductResponse
)
def get_product(
    product_id: int,
    db: Session = Depends(get_db)
):

    # Public endpoint
    product = db.query(Product).filter(
        Product.id == product_id
    ).first()

    if not product:
        raise HTTPException(
            status_code=404,
            detail="Product not found"
        )

    return product


# ============================================================
# UPDATE PRODUCT
# ============================================================

@router.put(
    "/{product_id}",
    response_model=ProductResponse
)
def update_product(
    product_id: int,
    product_data: ProductUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):

    product = db.query(Product).filter(
        Product.id == product_id
    ).first()

    if not product:
        raise HTTPException(
            status_code=404,
            detail="Product not found"
        )

    # Only the product owner can update it
    if product.seller_id != current_user.id:
        raise HTTPException(
            status_code=403,
            detail="You can only update your own products"
        )

    update_data = product_data.model_dump(
        exclude_unset=True
    )

    # Prevent changing the seller
    update_data.pop("seller_id", None)

    for key, value in update_data.items():
        setattr(product, key, value)

    db.commit()
    db.refresh(product)

    return product


# ============================================================
# DELETE PRODUCT
# ============================================================

@router.delete(
    "/{product_id}"
)
def delete_product(
    product_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):

    product = db.query(Product).filter(
        Product.id == product_id
    ).first()

    if not product:
        raise HTTPException(
            status_code=404,
            detail="Product not found"
        )

    # Only the product owner can delete it
    if product.seller_id != current_user.id:
        raise HTTPException(
            status_code=403,
            detail="You can only delete your own products"
        )

    db.delete(product)
    db.commit()

    return {
        "message": "Product deleted successfully"
    }