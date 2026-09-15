# ============================================================
# KALASETU FASTAPI DOCKERFILE
# ============================================================

FROM python:3.12-slim

# Prevent Python from creating .pyc files
ENV PYTHONDONTWRITEBYTECODE=1

# Display Python output immediately
ENV PYTHONUNBUFFERED=1

# Set working directory inside container
WORKDIR /app

# Copy Python dependencies
COPY Backend/app/requirements.txt ./requirements.txt

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the FastAPI application
COPY Backend/app ./app

# Start FastAPI
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]