@echo off
echo ========================================================
echo   Launching KalaSetu (ArtisanX) - Complete Full Stack
echo ========================================================
echo.
cd /d "%~dp0"

echo 1. Starting FastAPI Backend Server (Port 8000)...
start "KalaSetu Backend" cmd /k "cd /d "%~dp0Backend" && python -m uvicorn app.main:app --host 127.0.0.1 --port 8000 --reload"

echo Waiting 2 seconds for backend initialization...
timeout /t 2 /nobreak >nul

echo 2. Opening KalaSetu Web App in Default Browser...
start "" "http://localhost:8080"

echo 3. Starting Frontend Web Server (Port 8080)...
where npx >nul 2>nul
if %errorlevel% equ 0 (
    npx -y serve build/web -l 8080
) else (
    python -m http.server 8080 -d build/web
)
pause
