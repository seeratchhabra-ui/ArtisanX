@echo off
echo ========================================================
echo   Launching KalaSetu (ArtisanX) Frontend App
echo ========================================================
echo.
cd /d "%~dp0"
echo Starting web server on http://localhost:8080...
start "" "http://localhost:8080"
npx -y serve build/web -l 8080
pause
