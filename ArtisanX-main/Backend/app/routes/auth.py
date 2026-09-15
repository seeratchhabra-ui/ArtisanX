# ============================================================
# KALASETU - USER AUTHENTICATION ROUTES
# ============================================================

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from pydantic import BaseModel

from ..database import get_db
from ..models import User, UserRole
from ..schemas import UserCreate
from ..auth import (
    create_otp,
    verify_otp,
    create_access_token,
    get_current_user,
)


# ============================================================
# ROUTER
# ============================================================

router = APIRouter(
    prefix="/api/auth",
    tags=["Authentication"]
)


# ============================================================
# REQUEST SCHEMAS
# ============================================================

class OTPRequest(BaseModel):
    phone: str


class OTPLoginRequest(BaseModel):
    phone: str
    otp: str


# ============================================================
# 1. REGISTER USER
# ============================================================

@router.post("/register")
def register_user(
    user_data: UserCreate,
    db: Session = Depends(get_db)
):
    """
    Register a new KalaSetu user.

    Normal registration allows:
    - CUSTOMER
    - ARTISAN

    ADMIN cannot register themselves.
    Admin accounts must be created/assigned
    through a protected administrative process.
    """

    # --------------------------------------------------------
    # PREVENT SELF-REGISTRATION AS ADMIN
    # --------------------------------------------------------

    if user_data.role == UserRole.ADMIN:

        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Admin accounts cannot be created through public registration"
        )

    # --------------------------------------------------------
    # CHECK EMAIL
    # --------------------------------------------------------

    existing_email = (
        db.query(User)
        .filter(User.email == user_data.email)
        .first()
    )

    if existing_email:

        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already registered"
        )

    # --------------------------------------------------------
    # CHECK PHONE
    # --------------------------------------------------------

    if user_data.phone:

        existing_phone = (
            db.query(User)
            .filter(User.phone == user_data.phone)
            .first()
        )

        if existing_phone:

            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Phone number already registered"
            )

    # --------------------------------------------------------
    # CREATE USER
    # --------------------------------------------------------

    new_user = User(
        name=user_data.name,
        email=user_data.email,
        phone=user_data.phone,
        role=user_data.role.value,
    )

    db.add(new_user)

    db.commit()

    db.refresh(new_user)

    # --------------------------------------------------------
    # RESPONSE
    # --------------------------------------------------------

    return {
        "message": "User registered successfully",
        "user": new_user
    }


# ============================================================
# 2. REQUEST OTP
# ============================================================

@router.post("/request-otp")
def request_otp(
    data: OTPRequest,
    db: Session = Depends(get_db)
):
    """
    Generate an OTP for mobile login.

    For development, the OTP is returned in the response.
    """

    user = (
        db.query(User)
        .filter(User.phone == data.phone)
        .first()
    )

    if not user:

        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User with this phone number does not exist"
        )

    otp = create_otp(data.phone)

    return {
        "message": "OTP generated successfully",
        "phone": data.phone,
        "debug_otp": otp
    }


# ============================================================
# 3. LOGIN WITH OTP
# ============================================================

@router.post("/login")
def login(
    data: OTPLoginRequest,
    db: Session = Depends(get_db)
):
    """
    Verify OTP and generate a JWT access token.
    """

    # --------------------------------------------------------
    # VERIFY OTP
    # --------------------------------------------------------

    if not verify_otp(data.phone, data.otp):

        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired OTP"
        )

    # --------------------------------------------------------
    # FIND USER
    # --------------------------------------------------------

    user = (
        db.query(User)
        .filter(User.phone == data.phone)
        .first()
    )

    if not user:

        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )

    # --------------------------------------------------------
    # CREATE JWT
    # --------------------------------------------------------

    access_token = create_access_token(
        data={
            "sub": str(user.id)
        }
    )

    return {
        "message": "Login successful",
        "access_token": access_token,
        "token_type": "bearer"
    }


# ============================================================
# 4. GET CURRENT USER
# ============================================================

@router.get("/me")
def get_me(
    current_user: User = Depends(get_current_user)
):
    """
    Protected route.

    Returns the currently authenticated user.
    """

    return {
        "message": "Authenticated user",
        "user": current_user
    }