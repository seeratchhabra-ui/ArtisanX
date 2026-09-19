# ============================================================
# KALASETU - DATABASE CONFIGURATION
# ============================================================

import os
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base

# 1. Base URL determination
# In Docker Compose, DATABASE_URL is supplied via environment variables.
# When running locally, if PostgreSQL is not available, we gracefully fallback to SQLite.
RAW_DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "postgresql+psycopg://kalasetu:kalasetu_password@localhost:5432/kalasetu_db"
)

DATABASE_URL = RAW_DATABASE_URL
engine = None

if DATABASE_URL.startswith("sqlite"):
    engine = create_engine(
        DATABASE_URL,
        connect_args={"check_same_thread": False}
    )
else:
    try:
        engine = create_engine(
            DATABASE_URL,
            pool_pre_ping=True,
            connect_args={"connect_timeout": 2} if "psycopg" in DATABASE_URL else {}
        )
        # Quick ping test to verify server availability
        with engine.connect() as conn:
            pass
    except Exception as e:
        # Fallback to SQLite for resilient local offline development
        print(f"[KalaSetu DB] PostgreSQL connection to {DATABASE_URL} unavailable: {e}")
        print("[KalaSetu DB] Falling back gracefully to local SQLite database (kalasetu.db)")
        DATABASE_URL = "sqlite:///./kalasetu.db"
        engine = create_engine(
            DATABASE_URL,
            connect_args={"check_same_thread": False}
        )

# Database Session
SessionLocal = sessionmaker(
    autocommit=False,
    autoflush=False,
    bind=engine
)

# Base Model Class
Base = declarative_base()

# Dependency for FastAPI routes
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()