@echo off
echo ========================================================
echo   Launching KalaSetu (ArtisanX) Web Frontend
echo ========================================================
echo.
cd /d "%~dp0"
echo Starting web server on http://localhost:8080...
start "" "http://localhost:8080"

where npx >nul 2>nul
if %errorlevel% equ 0 (
    npx -y serve build/web -l 8080
) else (
    python -m http.server 8080 -d build/web
)
pause
