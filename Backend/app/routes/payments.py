# ============================================================
# KALASETU - RAZORPAY PAYMENT ROUTES
# ============================================================

from decimal import Decimal
from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from sqlalchemy.orm import Session

from ..database import get_db
from ..models import Order, User
from ..auth import get_current_user
from ..services.payment_service import (
    create_razorpay_order,
    verify_payment_signature,
    _get_razorpay_keys,
)

router = APIRouter(
    prefix="/api/payments",
    tags=["Payments"]
)


# ============================================================
# SCHEMAS
# ============================================================

class CreatePaymentOrderRequest(BaseModel):
    amount: float
    order_id: int | None = None
    product_name: str | None = None


class VerifyPaymentRequest(BaseModel):
    razorpay_order_id: str
    razorpay_payment_id: str
    razorpay_signature: str
    order_id: int | None = None


# ============================================================
# 1. CREATE RAZORPAY ORDER
# ============================================================

@router.post("/create-order")
def create_payment_order(
    req: CreatePaymentOrderRequest,
    current_user: User = Depends(get_current_user),
):
    """
    Create a Razorpay order before initiating checkout.
    Returns razorpay order_id, amount in paise, currency, and key_id.
    """
    if req.amount <= 0:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Order amount must be greater than 0",
        )

    receipt_tag = f"order_{req.order_id}" if req.order_id else f"cart_{current_user.id}"
    notes = {
        "customer_id": str(current_user.id),
        "customer_name": current_user.name,
        "product_name": req.product_name or "Handicraft Cart",
    }

    rzp_order = create_razorpay_order(
        amount_in_rupees=req.amount,
        receipt=receipt_tag,
        notes=notes,
    )

    return rzp_order


# ============================================================
# 2. VERIFY PAYMENT & MARK ORDER PAID
# ============================================================

@router.post("/verify")
def verify_payment(
    req: VerifyPaymentRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """
    Verify payment cryptographic signature from Razorpay.
    Upon verification, updates the order status in the database to 'processing' / 'paid'.
    """
    is_valid = verify_payment_signature(
        razorpay_order_id=req.razorpay_order_id,
        razorpay_payment_id=req.razorpay_payment_id,
        razorpay_signature=req.razorpay_signature,
    )

    if not is_valid:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid payment signature. Transaction verification failed.",
        )

    # If linked to an internal database order, update status to processing
    if req.order_id:
        order = db.query(Order).filter(Order.id == req.order_id).first()
        if order:
            order.status = "processing"
            db.commit()
            db.refresh(order)

    return {
        "status": "success",
        "message": "Payment verified successfully. Order confirmed.",
        "razorpay_order_id": req.razorpay_order_id,
        "razorpay_payment_id": req.razorpay_payment_id,
        "order_id": req.order_id,
    }


# ============================================================
# 3. GET RAZORPAY CONFIGURATION (Key ID for frontend)
# ============================================================

@router.get("/config")
def get_payment_config():
    """Returns Razorpay Public Key ID so frontend can initialize checkout."""
    key_id, _ = _get_razorpay_keys()
    return {
        "key_id": key_id,
        "currency": "INR",
        "name": "KalaSetu Handicrafts",
    }
