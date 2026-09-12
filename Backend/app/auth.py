# ============================================================
# KALASETU - AUTHENTICATION & JWT
# ============================================================
#
# THIS FILE CONTAINS:
# ✅ OTP generation
# ✅ Development OTP verification
# ✅ Password hashing utilities for future use
# ✅ JWT access token creation
# ✅ JWT token verification
# ✅ Current authenticated user dependency
#
# CURRENTLY NOT ADDED:
# ❌ Real SMS provider
# ❌ Firebase authentication
# ❌ Email authentication
# ❌ Refresh tokens
# ❌ Role-based authorization
#
# ============================================================


# ============================================================
# IMPORTS
# ============================================================

import os
import random

from datetime import datetime, timedelta, timezone

from fastapi import Depends, HTTPException, status

from fastapi.security import (
    HTTPBearer,
    HTTPAuthorizationCredentials
)

from jose import JWTError, jwt

from passlib.context import CryptContext

from sqlalchemy.orm import Session

from .database import get_db
from .models import User


# ============================================================
# JWT CONFIGURATION
# ============================================================

SECRET_KEY = os.getenv(
    "SECRET_KEY",
    "KALASETU-DEVELOPMENT-SECRET-CHANGE-IN-PRODUCTION"
)

ALGORITHM = "HS256"

ACCESS_TOKEN_EXPIRE_MINUTES = int(
    os.getenv(
        "ACCESS_TOKEN_EXPIRE_MINUTES",
        "30"
    )
)


# ============================================================
# PASSWORD HASHING
# ============================================================

pwd_context = CryptContext(
    schemes=["bcrypt"],
    deprecated="auto"
)


# ============================================================
# PASSWORD FUNCTIONS
# ============================================================

def hash_password(password: str) -> str:
    """
    Convert a plain password into a secure hash.
    """

    return pwd_context.hash(password)


def verify_password(
    plain_password: str,
    hashed_password: str
) -> bool:
    """
    Verify a password against its stored hash.
    """

    return pwd_context.verify(
        plain_password,
        hashed_password
    )


# ============================================================
# OTP GENERATION
# ============================================================

def generate_otp() -> str:
    """
    Generate a six-digit OTP.
    """

    return str(
        random.randint(
            100000,
            999999
        )
    )


# ============================================================
# DEVELOPMENT OTP STORAGE
# ============================================================
#
# IMPORTANT:
# This dictionary is ONLY for development/testing.
#
# Later this can be replaced with Redis or another
# temporary OTP storage system.
#
# ============================================================

otp_store: dict[str, str] = {}


# ============================================================
# CREATE OTP
# ============================================================

def create_otp(phone: str) -> str:
    """
    Generate and temporarily store an OTP
    for a phone number.
    """

    otp = generate_otp()

    otp_store[phone] = otp

    return otp


# ============================================================
# VERIFY OTP
# ============================================================

def verify_otp(
    phone: str,
    otp: str
) -> bool:
    """
    Check whether the supplied OTP matches
    the stored OTP.
    """

    stored_otp = otp_store.get(phone)

    if stored_otp is None:
        return False

    if stored_otp != otp:
        return False

    # Delete OTP after successful verification.
    # This prevents reuse.

    del otp_store[phone]

    return True


# ============================================================
# CREATE JWT ACCESS TOKEN
# ============================================================

def create_access_token(
    data: dict,
    expires_delta: timedelta | None = None
) -> str:
    """
    Create a signed JWT access token.

    Example payload:

    {
        "sub": "1"
    }

    "sub" represents the authenticated user's ID.
    """

    to_encode = data.copy()

    # Calculate expiration time

    if expires_delta:

        expire = (
            datetime.now(timezone.utc)
            + expires_delta
        )

    else:

        expire = (
            datetime.now(timezone.utc)
            + timedelta(
                minutes=ACCESS_TOKEN_EXPIRE_MINUTES
            )
        )

    # Add expiration to token

    to_encode.update(
        {
            "exp": expire
        }
    )

    # Create signed JWT

    encoded_jwt = jwt.encode(
        to_encode,
        SECRET_KEY,
        algorithm=ALGORITHM
    )

    return encoded_jwt


# ============================================================
# HTTP BEARER TOKEN
# ============================================================
#
# This allows Swagger to use:
#
# Authorization: Bearer <JWT>
#
# Instead of asking for:
#
# username
# password
# client_id
# client_secret
#
# This matches our OTP + JWT authentication system.
#
# ============================================================

bearer_scheme = HTTPBearer()


# ============================================================
# GET CURRENT USER
# ============================================================
#
# Protected routes can use:
#
# current_user: User = Depends(get_current_user)
#
# Authentication flow:
#
# Request
#    ↓
# Bearer JWT
#    ↓
# Decode JWT
#    ↓
# Get user ID
#    ↓
# Find user in PostgreSQL
#    ↓
# Authenticated user
#
# ============================================================

def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(
        bearer_scheme
    ),
    db: Session = Depends(get_db)
) -> User:

    # --------------------------------------------------------
    # Get JWT token from Authorization header
    # --------------------------------------------------------

    token = credentials.credentials


    # --------------------------------------------------------
    # Error for invalid authentication
    # --------------------------------------------------------

    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate authentication credentials",
        headers={
            "WWW-Authenticate": "Bearer"
        }
    )


    # --------------------------------------------------------
    # Decode JWT
    # --------------------------------------------------------

    try:

        payload = jwt.decode(
            token,
            SECRET_KEY,
            algorithms=[ALGORITHM]
        )

        # Get user ID from "sub"

        user_id = payload.get("sub")

        if user_id is None:
            raise credentials_exception

    except JWTError:

        raise credentials_exception


    # --------------------------------------------------------
    # Find user in PostgreSQL
    # --------------------------------------------------------

    try:

        user = db.query(User).filter(
            User.id == int(user_id)
        ).first()

    except (ValueError, TypeError):

        raise credentials_exception


    # --------------------------------------------------------
    # User doesn't exist
    # --------------------------------------------------------

    if user is None:

        raise credentials_exception


    # --------------------------------------------------------
    # Return authenticated user
    # --------------------------------------------------------

    return user