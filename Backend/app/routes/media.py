# ============================================================
# KALASETU - PRODUCT MEDIA ROUTES
# ============================================================

from pathlib import Path

from fastapi import (
    APIRouter,
    Depends,
    File,
    HTTPException,
    UploadFile,
    status
)

from sqlalchemy.orm import Session

from ..database import get_db
from ..models import (
    Product,
    ProductMedia,
    User
)

from ..auth import get_current_user
from ..services.media_service import (
    generate_storage_filename,
    get_product_directory
)


# ============================================================
# ROUTER
# ============================================================

router = APIRouter(
    prefix="/api/products",
    tags=["Product Media"]
)


# ============================================================
# CONFIGURATION
# ============================================================

ALLOWED_IMAGE_TYPES = {
    "image/jpeg",
    "image/png",
    "image/webp"
}

ALLOWED_VIDEO_TYPES = {
    "video/mp4",
    "video/webm"
}

MAX_IMAGE_SIZE = 10 * 1024 * 1024
MAX_VIDEO_SIZE = 100 * 1024 * 1024


# ============================================================
# UPLOAD PRODUCT MEDIA
# ============================================================

@router.post(
    "/{product_id}/media"
)
async def upload_product_media(
    product_id: int,
    files: list[UploadFile] = File(...),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):

    # --------------------------------------------------------
    # FIND PRODUCT
    # --------------------------------------------------------

    product = (
        db.query(Product)
        .filter(Product.id == product_id)
        .first()
    )

    if not product:
        raise HTTPException(
            status_code=404,
            detail="Product not found"
        )

    # --------------------------------------------------------
    # CHECK PRODUCT OWNERSHIP
    # --------------------------------------------------------

    if product.seller_id != current_user.id:
        raise HTTPException(
            status_code=403,
            detail="You can only upload media for your own products"
        )

    # --------------------------------------------------------
    # CHECK FILE COUNT
    # --------------------------------------------------------

    if not files:
        raise HTTPException(
            status_code=400,
            detail="At least one file is required"
        )

    # --------------------------------------------------------
    # PRODUCT DIRECTORY
    # --------------------------------------------------------

    product_directory = get_product_directory(
        product_id
    )

    # --------------------------------------------------------
    # EXISTING MEDIA COUNT
    # --------------------------------------------------------

    existing_media_count = (
        db.query(ProductMedia)
        .filter(
            ProductMedia.product_id == product_id
        )
        .count()
    )

    uploaded_media = []

    # --------------------------------------------------------
    # PROCESS EACH FILE
    # --------------------------------------------------------

    for index, file in enumerate(files):

        if not file.filename:
            raise HTTPException(
                status_code=400,
                detail="One of the uploaded files has no filename"
            )

        content_type = file.content_type

        # ----------------------------------------------------
        # DETERMINE MEDIA TYPE
        # ----------------------------------------------------

        if content_type in ALLOWED_IMAGE_TYPES:

            media_type = "image"
            max_size = MAX_IMAGE_SIZE

        elif content_type in ALLOWED_VIDEO_TYPES:

            media_type = "video"
            max_size = MAX_VIDEO_SIZE

        else:

            raise HTTPException(
                status_code=400,
                detail=(
                    f"Unsupported file type: {content_type}. "
                    "Allowed images: JPEG, PNG, WEBP. "
                    "Allowed videos: MP4, WEBM."
                )
            )

        # ----------------------------------------------------
        # READ FILE
        # ----------------------------------------------------

        file_content = await file.read()

        file_size = len(file_content)

        # ----------------------------------------------------
        # CHECK FILE SIZE
        # ----------------------------------------------------

        if file_size > max_size:

            raise HTTPException(
                status_code=400,
                detail=(
                    f"File '{file.filename}' exceeds "
                    f"the maximum allowed size."
                )
            )

        if file_size == 0:

            raise HTTPException(
                status_code=400,
                detail=f"File '{file.filename}' is empty"
            )

        # ----------------------------------------------------
        # GENERATE SAFE STORAGE NAME
        # ----------------------------------------------------

        stored_filename = generate_storage_filename(
            file.filename
        )

        file_path = (
            product_directory /
            stored_filename
        )

        # ----------------------------------------------------
        # SAVE FILE
        # ----------------------------------------------------

        try:

            with open(
                file_path,
                "wb"
            ) as output_file:

                output_file.write(
                    file_content
                )

        except Exception as error:

            raise HTTPException(
                status_code=500,
                detail=f"Failed to save file: {str(error)}"
            )

        # ----------------------------------------------------
        # DISPLAY ORDER
        # ----------------------------------------------------

        display_order = (
            existing_media_count + index
        )

        # ----------------------------------------------------
        # FIRST IMAGE BECOMES PRIMARY
        # ----------------------------------------------------

        existing_primary = (
            db.query(ProductMedia)
            .filter(
                ProductMedia.product_id == product_id,
                ProductMedia.is_primary == True
            )
            .first()
        )

        is_primary = (
            media_type == "image"
            and existing_primary is None
        )

        # ----------------------------------------------------
        # DATABASE RECORD
        # ----------------------------------------------------

        media = ProductMedia(

            product_id=product_id,

            original_filename=file.filename,

            stored_filename=stored_filename,

            file_path=str(
                file_path
            ),

            media_type=media_type,

            mime_type=content_type,

            file_size=file_size,

            display_order=display_order,

            is_primary=is_primary,

            ai_status="pending"
        )

        db.add(media)

        uploaded_media.append(media)

    # --------------------------------------------------------
    # COMMIT
    # --------------------------------------------------------

    db.commit()

    # Refresh records
    for media in uploaded_media:
        db.refresh(media)

    # --------------------------------------------------------
    # RESPONSE
    # --------------------------------------------------------

    return {
        "message": "Media uploaded successfully",
        "product_id": product_id,
        "files": [
            {
                "id": media.id,
                "filename": media.original_filename,

                # Public URL for the uploaded media
                "url": (
                    "/uploads/products/"
                    f"{product_id}/"
                    f"{media.stored_filename}"
                ),

                "media_type": media.media_type,
                "mime_type": media.mime_type,
                "file_size": media.file_size,
                "display_order": media.display_order,
                "is_primary": media.is_primary,
                "ai_status": media.ai_status
            }
            for media in uploaded_media
        ]
    }


# ============================================================
# GET PRODUCT MEDIA
# ============================================================

@router.get(
    "/{product_id}/media"
)
def get_product_media(
    product_id: int,
    db: Session = Depends(get_db)
):

    product = (
        db.query(Product)
        .filter(Product.id == product_id)
        .first()
    )

    if not product:
        raise HTTPException(
            status_code=404,
            detail="Product not found"
        )

    media = (
        db.query(ProductMedia)
        .filter(
            ProductMedia.product_id == product_id
        )
        .order_by(
            ProductMedia.display_order
        )
        .all()
    )

    return {
        "product_id": product_id,
        "media": [
            {
                "id": item.id,
                "filename": item.original_filename,

                # Public URL for the uploaded media
                "url": (
                    "/uploads/products/"
                    f"{product_id}/"
                    f"{item.stored_filename}"
                ),

                "media_type": item.media_type,
                "mime_type": item.mime_type,
                "file_size": item.file_size,
                "display_order": item.display_order,
                "is_primary": item.is_primary,
                "ai_status": item.ai_status
            }
            for item in media
        ]
    }


# ============================================================
# DELETE PRODUCT MEDIA
# ============================================================

@router.delete(
    "/media/{media_id}"
)
def delete_product_media(
    media_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):

    media = (
        db.query(ProductMedia)
        .filter(
            ProductMedia.id == media_id
        )
        .first()
    )

    if not media:
        raise HTTPException(
            status_code=404,
            detail="Media not found"
        )

    product = (
        db.query(Product)
        .filter(
            Product.id == media.product_id
        )
        .first()
    )

    if not product:
        raise HTTPException(
            status_code=404,
            detail="Product not found"
        )

    # --------------------------------------------------------
    # OWNERSHIP
    # --------------------------------------------------------

    if product.seller_id != current_user.id:
        raise HTTPException(
            status_code=403,
            detail="You can only delete your own product media"
        )

    # --------------------------------------------------------
    # DELETE PHYSICAL FILE
    # --------------------------------------------------------

    file_path = Path(
        media.file_path
    )

    if file_path.exists():
        file_path.unlink()

    # --------------------------------------------------------
    # DELETE DATABASE RECORD
    # --------------------------------------------------------

    db.delete(media)

    db.commit()

    return {
        "message": "Media deleted successfully"
    }