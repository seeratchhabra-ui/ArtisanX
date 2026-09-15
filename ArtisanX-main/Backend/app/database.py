# ============================================================
# KALASETU - DATABASE CONFIGURATION
# ============================================================
#
# ADDED:
# ✅ PostgreSQL connection
# ✅ SQLAlchemy engine
# ✅ Database sessions
#
# NOT ADDED:
# ❌ Authentication
# ❌ JWT
# ❌ AI/ML
# ❌ Gemini
# ❌ Bhashini
# ❌ Flutter
#
# ============================================================

import os

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base


# ============================================================
# DATABASE URL
# ============================================================
#
# Docker Compose supplies DATABASE_URL.
#
# When running inside Docker:
#
# postgres = PostgreSQL container name
#
# ============================================================

DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "postgresql+psycopg://kalasetu:kalasetu_password@localhost:5432/kalasetu_db"
)


# ============================================================
# SQLALCHEMY ENGINE
# ============================================================

engine = create_engine(
    DATABASE_URL,
    pool_pre_ping=True
)


# ============================================================
# DATABASE SESSION
# ============================================================

SessionLocal = sessionmaker(
    autocommit=False,
    autoflush=False,
    bind=engine
)


# ============================================================
# BASE CLASS
# ============================================================

Base = declarative_base()


# ============================================================
# DATABASE DEPENDENCY
# ============================================================

def get_db():

    db = SessionLocal()

    try:
        yield db

    finally:
        db.close()