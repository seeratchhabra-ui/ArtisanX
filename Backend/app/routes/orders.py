# ============================================================
# KALASETU - ORDER CRUD
# ============================================================

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from ..database import get_db
from ..models import Order, User, Product
from ..schemas import (
    OrderCreate,
    OrderUpdate,
    OrderResponse
)
from ..auth import get_current_user


router = APIRouter(
    prefix="/api/orders",
    tags=["Orders"]
)


# ============================================================
# CREATE ORDER
# ============================================================

@router.post(
    "/",
    response_model=OrderResponse
)
def create_order(
    order: OrderCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):

    # --------------------------------------------------------
    # Make sure order belongs to logged-in user
    # --------------------------------------------------------

    if order.user_id != current_user.id:
        raise HTTPException(
            status_code=403,
            detail="You can only create orders for your own account"
        )

    # --------------------------------------------------------
    # Check user
    # --------------------------------------------------------

    user = db.query(User).filter(
        User.id == current_user.id
    ).first()

    if not user:
        raise HTTPException(
            status_code=404,
            detail="User not found"
        )

    # --------------------------------------------------------
    # Check product
    # --------------------------------------------------------

    product = db.query(Product).filter(
        Product.id == order.product_id
    ).first()

    if not product:
        raise HTTPException(
            status_code=404,
            detail="Product not found"
        )

    # --------------------------------------------------------
    # Check quantity
    # --------------------------------------------------------

    if order.quantity <= 0:
        raise HTTPException(
            status_code=400,
            detail="Quantity must be greater than 0"
        )

    # --------------------------------------------------------
    # Check stock
    # --------------------------------------------------------

    if product.stock < order.quantity:
        raise HTTPException(
            status_code=400,
            detail="Not enough stock available"
        )

    # --------------------------------------------------------
    # Calculate total price
    # --------------------------------------------------------

    total_price = product.price * order.quantity

    # --------------------------------------------------------
    # Create order
    # --------------------------------------------------------

    new_order = Order(
        user_id=current_user.id,
        product_id=order.product_id,
        quantity=order.quantity,
        total_price=total_price,
        status="pending"
    )

    # --------------------------------------------------------
    # Reduce stock
    # --------------------------------------------------------

    product.stock -= order.quantity

    # --------------------------------------------------------
    # Save everything
    # --------------------------------------------------------

    db.add(new_order)

    db.commit()

    db.refresh(new_order)

    return new_order


# ============================================================
# GET ALL ORDERS
# ============================================================

@router.get(
    "/",
    response_model=list[OrderResponse]
)
def get_orders(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):

    # Only return orders belonging to logged-in user
    return db.query(Order).filter(
        Order.user_id == current_user.id
    ).all()


# ============================================================
# GET ONE ORDER
# ============================================================

@router.get(
    "/{order_id}",
    response_model=OrderResponse
)
def get_order(
    order_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):

    order = db.query(Order).filter(
        Order.id == order_id
    ).first()

    if not order:
        raise HTTPException(
            status_code=404,
            detail="Order not found"
        )

    # Only owner can view order
    if order.user_id != current_user.id:
        raise HTTPException(
            status_code=403,
            detail="You can only access your own orders"
        )

    return order


# ============================================================
# UPDATE ORDER STATUS
# ============================================================

@router.put(
    "/{order_id}",
    response_model=OrderResponse
)
def update_order(
    order_id: int,
    order_data: OrderUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):

    order = db.query(Order).filter(
        Order.id == order_id
    ).first()

    if not order:
        raise HTTPException(
            status_code=404,
            detail="Order not found"
        )

    # Only owner can update order
    if order.user_id != current_user.id:
        raise HTTPException(
            status_code=403,
            detail="You can only update your own orders"
        )

    order.status = order_data.status

    db.commit()

    db.refresh(order)

    return order


# ============================================================
# DELETE ORDER
# ============================================================

@router.delete(
    "/{order_id}"
)
def delete_order(
    order_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):

    order = db.query(Order).filter(
        Order.id == order_id
    ).first()

    if not order:
        raise HTTPException(
            status_code=404,
            detail="Order not found"
        )

    # Only owner can delete order
    if order.user_id != current_user.id:
        raise HTTPException(
            status_code=403,
            detail="You can only delete your own orders"
        )

    db.delete(order)

    db.commit()

    return {
        "message": "Order deleted successfully"
    }
