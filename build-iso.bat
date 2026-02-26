@echo off
echo =========================================
echo   IWILL Signage ISO Builder
echo =========================================
echo.

REM Check if Docker is running
docker info >nul 2>&1
if errorlevel 1 (
    echo ERROR: Docker is not running!
    echo Please start Docker Desktop first.
    pause
    exit /b 1
)

echo Step 1: Building Docker image...
docker-compose build
if errorlevel 1 (
    echo ERROR: Failed to build Docker image
    pause
    exit /b 1
)

echo.
echo Step 2: Building ISO (this takes 30-60 minutes)...
echo.
docker-compose up
if errorlevel 1 (
    echo ERROR: ISO build failed
    pause
    exit /b 1
)

echo.
echo =========================================
echo   BUILD COMPLETE!
echo =========================================
echo.
echo ISO file location:
dir output\*.iso /b 2>nul
if errorlevel 1 (
    echo WARNING: ISO file not found in output folder
) else (
    echo.
    echo Next steps:
    echo 1. Use Rufus to flash the ISO to USB
    echo 2. Boot N3322 from USB
    echo 3. Select "Install IWILL Signage (Automated)"
)
echo.
pause
