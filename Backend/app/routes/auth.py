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


from ..services.sms_service import dispatch_otp, verify_otp_code

# ============================================================
# 2. REQUEST OTP
# ============================================================

@router.post("/request-otp")
def request_otp(
    data: OTPRequest,
    db: Session = Depends(get_db)
):
    """
    Generate and dispatch an OTP for mobile login via SMS gateway
    (Fast2SMS / Twilio) or dev console fallback.
    """
    result = dispatch_otp(data.phone)
    # Also keep legacy in-memory auth table in sync
    create_otp(data.phone)

    return {
        "message": result["message"],
        "phone": data.phone,
        "debug_otp": result["otp"],
        "sms_sent": result["sms_sent"],
        "provider": result["provider"],
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
    Supports development OTP (123456), SMS OTP, or dynamically generated OTP.
    """
    # --------------------------------------------------------
    # VERIFY OTP
    # --------------------------------------------------------
    is_valid_otp = (
        (data.otp == "123456")
        or verify_otp_code(data.phone, data.otp)
        or verify_otp(data.phone, data.otp)
    )

    if not is_valid_otp:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired OTP. Please try again."
        )

    # --------------------------------------------------------
    # FIND USER (Clean phone normalization)
    # --------------------------------------------------------
    clean_digits = "".join(filter(str.isdigit, data.phone))
    all_users = db.query(User).all()
    user = None
    for u in all_users:
        u_digits = "".join(filter(str.isdigit, u.phone or ""))
        if u_digits and (u_digits in clean_digits or clean_digits in u_digits):
            user = u
            break

    if not user:
        # Seamless onboarding for new user
        user = User(
            name="Asha Devi",
            email=f"user_{clean_digits}@kalasetu.in",
            phone=data.phone,
            role=UserRole.ARTISAN.value
        )
        db.add(user)
        db.commit()
        db.refresh(user)

    # --------------------------------------------------------
    # CREATE JWT
    # --------------------------------------------------------
    access_token = create_access_token(
        data={"sub": str(user.id)}
    )

    profile_data = None
    if user.artisan_profile:
        profile_data = {
            "full_name": user.artisan_profile.full_name,
            "bio": user.artisan_profile.bio,
            "craft_type": user.artisan_profile.craft_type,
            "profile_image": user.artisan_profile.profile_image,
            "state": user.artisan_profile.state,
        }

    return {
        "message": "Login successful",
        "access_token": access_token,
        "token_type": "bearer",
        "user": {
            "id": user.id,
            "name": user.name,
            "email": user.email,
            "phone": user.phone,
            "role": user.role,
            "artisan_profile": profile_data,
        }
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