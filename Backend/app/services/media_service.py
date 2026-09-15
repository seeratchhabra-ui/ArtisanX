# ============================================================
# KALASETU - MEDIA STORAGE SERVICE
# ============================================================

from pathlib import Path
from uuid import uuid4


# ------------------------------------------------------------
# STORAGE LOCATION
# ------------------------------------------------------------

BASE_DIR = Path(__file__).resolve().parent.parent.parent

UPLOAD_DIR = BASE_DIR / "uploads" / "products"

UPLOAD_DIR.mkdir(
    parents=True,
    exist_ok=True
)


# ------------------------------------------------------------
# SAVE FILE
# ------------------------------------------------------------

def generate_storage_filename(
    original_filename: str
) -> str:

    extension = Path(
        original_filename
    ).suffix.lower()

    return f"{uuid4()}{extension}"


def get_product_directory(
    product_id: int
) -> Path:

    directory = UPLOAD_DIR / str(product_id)

    directory.mkdir(
        parents=True,
        exist_ok=True
    )

    return directory