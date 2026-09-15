# ============================================================
# KALASETU - ARTISAN PROFILE
# ============================================================
#
# FEATURES:
# ✅ Create artisan profile
# ✅ Get own artisan profile
# ✅ Update own artisan profile
#
# ACCESS:
# ✅ Requires JWT authentication
# ✅ Only users with ARTISAN role can access these routes
#
# ============================================================

from fastapi import APIRouter, Depends, HTTPException, status

from sqlalchemy.orm import Session

from ..database import get_db
from ..models import User, ArtisanProfile, UserRole
from ..schemas import (
    ArtisanProfileCreate,
    ArtisanProfileResponse
)
from ..auth import get_current_user


# ============================================================
# ROUTER
# ============================================================

router = APIRouter(
    prefix="/api/artisan",
    tags=["Artisan"]
)


# ============================================================
# CREATE ARTISAN PROFILE
# ============================================================

@router.post(
    "/profile",
    response_model=ArtisanProfileResponse,
    status_code=status.HTTP_201_CREATED
)
def create_artisan_profile(
    profile: ArtisanProfileCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):

    # --------------------------------------------------------
    # Check whether the authenticated user is an artisan
    # --------------------------------------------------------

    if current_user.role != UserRole.ARTISAN.value:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only artisans can create an artisan profile"
        )

    # --------------------------------------------------------
    # Check whether profile already exists
    # --------------------------------------------------------

    existing_profile = db.query(ArtisanProfile).filter(
        ArtisanProfile.user_id == current_user.id
    ).first()

    if existing_profile:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Artisan profile already exists"
        )

    # --------------------------------------------------------
    # Create profile
    # --------------------------------------------------------

    new_profile = ArtisanProfile(
        user_id=current_user.id,
        full_name=profile.full_name,
        bio=profile.bio,
        craft_type=profile.craft_type,
        experience_years=profile.experience_years,
        state=profile.state,
        district=profile.district,
        village=profile.village,
        profile_image=profile.profile_image
    )

    # --------------------------------------------------------
    # Save to database
    # --------------------------------------------------------

    db.add(new_profile)
    db.commit()
    db.refresh(new_profile)

    return new_profile


# ============================================================
# GET OWN ARTISAN PROFILE
# ============================================================

@router.get(
    "/profile",
    response_model=ArtisanProfileResponse
)
def get_artisan_profile(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):

    # --------------------------------------------------------
    # Check artisan role
    # --------------------------------------------------------

    if current_user.role != UserRole.ARTISAN.value:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only artisans can access an artisan profile"
        )

    # --------------------------------------------------------
    # Find profile belonging to current user
    # --------------------------------------------------------

    profile = db.query(ArtisanProfile).filter(
        ArtisanProfile.user_id == current_user.id
    ).first()

    if not profile:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Artisan profile not found"
        )

    return profile


# ============================================================
# UPDATE OWN ARTISAN PROFILE
# ============================================================

@router.put(
    "/profile",
    response_model=ArtisanProfileResponse
)
def update_artisan_profile(
    profile_data: ArtisanProfileCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):

    # --------------------------------------------------------
    # Check artisan role
    # --------------------------------------------------------

    if current_user.role != UserRole.ARTISAN.value:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only artisans can update an artisan profile"
        )

    # --------------------------------------------------------
    # Find existing profile
    # --------------------------------------------------------

    profile = db.query(ArtisanProfile).filter(
        ArtisanProfile.user_id == current_user.id
    ).first()

    if not profile:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Artisan profile not found"
        )

    # --------------------------------------------------------
    # Update profile fields
    # --------------------------------------------------------

    profile.full_name = profile_data.full_name
    profile.bio = profile_data.bio
    profile.craft_type = profile_data.craft_type
    profile.experience_years = profile_data.experience_years
    profile.state = profile_data.state
    profile.district = profile_data.district
    profile.village = profile_data.village
    profile.profile_image = profile_data.profile_image

    # --------------------------------------------------------
    # Save changes
    # --------------------------------------------------------

    db.commit()
    db.refresh(profile)

    return profile