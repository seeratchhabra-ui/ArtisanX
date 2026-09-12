# ============================================================
# KALASETU HERITAGE API ROUTES
# ============================================================

from fastapi import APIRouter, Depends

from sqlalchemy.orm import Session

from ..database import get_db
from ..models import HeritageSite
from ..schemas import (
    HeritageSiteCreate,
    HeritageSiteResponse
)


# ============================================================
# ROUTER
# ============================================================

router = APIRouter(
    prefix="/api/heritage",
    tags=["Heritage"]
)


# ============================================================
# CREATE HERITAGE SITE
# ============================================================
#
# POST /api/heritage
#
# This allows us to add a heritage site to PostgreSQL.
#
# ============================================================

@router.post(
    "/",
    response_model=HeritageSiteResponse
)
def create_heritage_site(
    site: HeritageSiteCreate,
    db: Session = Depends(get_db)
):

    # Convert API data into database model
    new_site = HeritageSite(
        name=site.name,
        description=site.description,
        location=site.location,
        state=site.state,
        category=site.category
    )


    # Add to database
    db.add(new_site)


    # Save changes
    db.commit()


    # Get generated ID
    db.refresh(new_site)


    return new_site


# ============================================================
# GET ALL HERITAGE SITES
# ============================================================
#
# GET /api/heritage
#
# Returns all heritage sites stored in PostgreSQL.
#
# ============================================================

@router.get(
    "/",
    response_model=list[HeritageSiteResponse]
)
def get_heritage_sites(
    db: Session = Depends(get_db)
):

    sites = db.query(HeritageSite).all()

    return sites