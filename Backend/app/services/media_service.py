# ============================================================
# KALASETU - MEDIA STORAGE SERVICE
# ============================================================

from pathlib import Path
from uuid import uuid4

# ------------------------------------------------------------
# STORAGE LOCATIONS
# ------------------------------------------------------------

BASE_DIR = Path(__file__).resolve().parent.parent.parent

PRODUCTS_UPLOAD_DIR = BASE_DIR / "uploads" / "products"
GENERAL_UPLOAD_DIR = BASE_DIR / "uploads" / "general"
AVATAR_UPLOAD_DIR = BASE_DIR / "uploads" / "avatars"

for d in [PRODUCTS_UPLOAD_DIR, GENERAL_UPLOAD_DIR, AVATAR_UPLOAD_DIR]:
    d.mkdir(parents=True, exist_ok=True)


# ------------------------------------------------------------
# FILENAME & PATH GENERATION
# ------------------------------------------------------------

def generate_storage_filename(original_filename: str) -> str:
    extension = Path(original_filename).suffix.lower()
    if not extension:
        extension = ".jpg"
    return f"{uuid4()}{extension}"


def get_product_directory(product_id: int) -> Path:
    directory = PRODUCTS_UPLOAD_DIR / str(product_id)
    directory.mkdir(parents=True, exist_ok=True)
    return directory


def get_general_directory() -> Path:
    return GENERAL_UPLOAD_DIR


def get_avatar_directory() -> Path:
    return AVATAR_UPLOAD_DIR