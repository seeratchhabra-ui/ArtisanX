# ============================================================
# KALASETU - FASTAPI MAIN APPLICATION
# ============================================================

from fastapi import FastAPI
from sqlalchemy import text

from .database import Base, engine, SessionLocal
from . import models

# Authentication router
from .routes import auth

# Other API routers
from .routes.heritage import router as heritage_router
from .routes.users import router as users_router
from .routes.products import router as products_router
from .routes.orders import router as orders_router


# ============================================================
# CREATE FASTAPI APPLICATION
# ============================================================

app = FastAPI(
    title="KalaSetu API",
    description="Backend API for the KalaSetu cultural heritage platform",
    version="0.3.0"
)


# ============================================================
# CREATE DATABASE TABLES
# ============================================================

Base.metadata.create_all(
    bind=engine
)


# ============================================================
# ROOT ENDPOINT
# ============================================================

@app.get("/")
def root():
    return {
        "message": "Welcome to KalaSetu API",
        "status": "running"
    }


# ============================================================
# BASIC HEALTH CHECK
# ============================================================

@app.get("/health")
def health_check():
    return {
        "status": "healthy"
    }


# ============================================================
# DATABASE HEALTH CHECK
# ============================================================

@app.get("/health/db")
def database_health_check():

    try:
        db = SessionLocal()

        db.execute(
            text("SELECT 1")
        )

        db.close()

        return {
            "status": "healthy",
            "database": "PostgreSQL",
            "connection": "successful"
        }

    except Exception as error:

        return {
            "status": "unhealthy",
            "database": "PostgreSQL",
            "connection": "failed",
            "error": str(error)
        }


# ============================================================
# REGISTER API ROUTES
# ============================================================

# Heritage API
app.include_router(
    heritage_router
)

# User CRUD API
app.include_router(
    users_router
)

# Product API
app.include_router(
    products_router
)

# Order API
app.include_router(
    orders_router
)

# Authentication API
app.include_router(
    auth.router,
    prefix=""
)


# ============================================================
# END OF MAIN APPLICATION
# ============================================================