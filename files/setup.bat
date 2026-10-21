@echo off
setlocal EnableExtensions
title AI Video App - Setup
cd /d "%~dp0"


REM Ensure optional model root exists; app can still run without downloaded models.
if not exist models mkdir models
echo =====================================
echo Setting up AI Video App
echo =====================================

REM Check Python
where python >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python not found. Install Python 3.11 or 3.12 and rerun setup.bat.
    exit /b 1
)

REM Create virtual environment
if not exist venv (
    python -m venv venv
    if errorlevel 1 (
        echo ERROR: Failed to create virtual environment.
        exit /b 1
    )
)

call venv\Scripts\activate

echo Installing dependencies...
python -m pip install --upgrade pip
if errorlevel 1 (
    echo ERROR: Failed to upgrade pip.
    exit /b 1
)

REM Install the core packages first so the app can run in manual image mode.
REM Keep TTS/AI extras best-effort below; the backend has runtime fallbacks.
python -m pip install fastapi uvicorn pydantic requests edge-tts imageio-ffmpeg python-multipart python-dotenv PyPDF2 python-pptx
if errorlevel 1 (
    echo ERROR: Failed to install required core dependencies.
    exit /b 1
)

REM Install full requirements, including optional AI packages. Do not block manual mode if optional AI fails.
if exist requirements.txt (
    python -m pip install -r requirements.txt
    if errorlevel 1 (
        echo Optional AI dependency install failed or was skipped. Continuing in manual image mode.
    )
) else (
    echo WARNING: requirements.txt not found. Core dependencies were installed only.
)

echo.

REM OPTIONAL MODEL DOWNLOAD FLAG
REM To enable model download on a target machine, run: set "DOWNLOAD_MODEL=true" && setup.bat
if not defined DOWNLOAD_MODEL set DOWNLOAD_MODEL=false

if /I "%DOWNLOAD_MODEL%"=="true" (
    echo Checking AI model...
    if exist models\stable-diffusion-v1-5 (
        echo Model already exists.
    ) else (
        echo Model not found. Downloading...
        python download_model.py
    )
) else (
    echo Skipping model download ^(manual image mode^)
)

echo =====================================
echo Setup Complete
echo =====================================

pause
exit /b 0
