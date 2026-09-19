# ============================================================
# KALASETU - FASTAPI MAIN APPLICATION
# ============================================================

from contextlib import asynccontextmanager
from pathlib import Path
from decimal import Decimal

from dotenv import load_dotenv
load_dotenv()

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from sqlalchemy import text

from .database import Base, engine, SessionLocal
from . import models

# Routers
from .routes import auth
from .routes.media import router as media_router, general_media_router
from .routes.heritage import router as heritage_router
from .routes.users import router as users_router
from .routes.products import router as products_router
from .routes.orders import router as orders_router
from .routes.artisan import router as artisan_router
from .routes.payments import router as payments_router
from .routes.ai import router as ai_router


# ============================================================
# SEED INITIAL DATA FOR DEVELOPMENT & TESTING
# ============================================================

def seed_database_if_empty():
    db = SessionLocal()
    try:
        if db.query(models.User).count() == 0:
            print("[KalaSetu] Seeding initial users, artisan profile, products, and orders...")

            # 1. Master Artisan User: Asha Devi
            artisan_user = models.User(
                name="Asha Devi",
                email="asha.devi@kalasetu.in",
                phone="+91 98765 43210",
                role=models.UserRole.ARTISAN.value,
            )
            db.add(artisan_user)
            db.flush()

            # Artisan Profile
            profile = models.ArtisanProfile(
                user_id=artisan_user.id,
                full_name="Asha Devi",
                bio="Master terracotta artisan preserving 4 generations of Blue Pottery & Glazed Clay heritage in Sanganer.",
                craft_type="Pottery",
                experience_years=18,
                state="Rajasthan",
                district="Jaipur",
                village="Sanganer",
                profile_image="https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=300&q=80",
            )
            db.add(profile)

            # 2. Customer User: Meera Shah
            customer_user = models.User(
                name="Meera Shah",
                email="meera.shah@gmail.com",
                phone="+91 98765 43210",
                role=models.UserRole.CUSTOMER.value,
            )
            db.add(customer_user)
            db.flush()

            # 3. Initial Products
            p1 = models.Product(
                name="Indigo Glaze Serving Bowl",
                description="Wheel-thrown by hand and finished with a deep indigo glaze. Every piece carries gentle variations that make it truly one of a kind. Crafted with organic clay sourced from local riverbeds and fired in a wood-burning kiln.",
                price=Decimal("1499.00"),
                category="Pottery",
                stock=14,
                state="Rajasthan",
                seller_id=artisan_user.id,
            )
            p2 = models.Product(
                name="Moonj Storage Basket",
                description="Handcrafted using wild Moonj and Kaasa grass collected sustainably from the riverbanks. Woven intricately with ancient coiling techniques, perfect for modern bohemian home storage.",
                price=Decimal("1290.00"),
                category="Baskets",
                stock=8,
                state="Uttar Pradesh",
                seller_id=artisan_user.id,
            )
            p3 = models.Product(
                name="Blue Glaze Kulhad (Set of 2)",
                description="Traditional Indian tea cups elevated with handcrafted indigo mineral slip. Enhances the earthy aroma of masala chai with its breathable natural terracotta base.",
                price=Decimal("849.00"),
                category="Pottery",
                stock=25,
                state="Rajasthan",
                seller_id=artisan_user.id,
            )
            p4 = models.Product(
                name="Terracotta Planter",
                description="Porous terracotta planter with hand-carved floral lattice motifs. Promotes healthy root aeration and moisture regulation for indoor and balcony plants.",
                price=Decimal("899.00"),
                category="Pottery",
                stock=12,
                state="Rajasthan",
                seller_id=artisan_user.id,
            )
            db.add_all([p1, p2, p3, p4])
            db.flush()

            # 4. Initial Orders
            o1 = models.Order(
                user_id=customer_user.id,
                product_id=p1.id,
                quantity=1,
                total_price=Decimal("1499.00"),
                status="processing",
            )
            o2 = models.Order(
                user_id=customer_user.id,
                product_id=p2.id,
                quantity=1,
                total_price=Decimal("1290.00"),
                status="ready_to_ship",
            )
            db.add_all([o1, o2])

            db.commit()
            print("[KalaSetu] Initial seed data created successfully.")
    except Exception as e:
        db.rollback()
        print(f"[KalaSetu Seed Error] {e}")
    finally:
        db.close()


# ============================================================
# LIFESPAN CONTEXT
# ============================================================

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Create tables
    Base.metadata.create_all(bind=engine)
    # Seed sample data
    seed_database_if_empty()
    yield


# ============================================================
# CREATE FASTAPI APPLICATION
# ============================================================

app = FastAPI(
    title="KalaSetu API",
    description="Backend API for the KalaSetu cultural heritage platform",
    version="0.3.0",
    lifespan=lifespan,
)


# ============================================================
# CORS CONFIGURATION
# ============================================================

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ============================================================
# PRODUCT MEDIA STORAGE
# ============================================================

UPLOAD_DIR = Path(__file__).resolve().parent.parent / "uploads"
UPLOAD_DIR.mkdir(parents=True, exist_ok=True)

app.mount(
    "/uploads",
    StaticFiles(directory=UPLOAD_DIR),
    name="uploads",
)


# ============================================================
# ROOT & HEALTH ENDPOINTS
# ============================================================

@app.get("/")
def root():
    return {
        "message": "Welcome to KalaSetu API",
        "status": "running",
        "version": "0.3.0",
    }


@app.get("/health")
@app.get("/api/health")
def health_check():
    return {
        "status": "healthy",
        "service": "KalaSetu API",
        "version": "0.3.0",
    }


@app.get("/health/db")
@app.get("/api/health/db")
def database_health_check():
    try:
        db = SessionLocal()
        db.execute(text("SELECT 1"))
        db.close()
        return {
            "status": "healthy",
            "connection": "successful",
        }
    except Exception as error:
        return {
            "status": "unhealthy",
            "connection": "failed",
            "error": str(error),
        }


# ============================================================
# REGISTER API ROUTES
# ============================================================

# Heritage API
app.include_router(heritage_router)

# User CRUD API
app.include_router(users_router)

# Product API
app.include_router(products_router)

# Product Media API
app.include_router(media_router)
app.include_router(general_media_router)

# Order API
app.include_router(orders_router)

# Artisan API
app.include_router(artisan_router)

# Razorpay Payments API
app.include_router(payments_router)

# Artificial Intelligence (Vision, Gemini, Bhashini) API
app.include_router(ai_router)

# Authentication API
app.include_router(auth.router, prefix="")