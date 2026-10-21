@echo off
setlocal EnableExtensions
title AI Video App - Lightweight Package
cd /d "%~dp0"

echo =====================================
echo Creating lightweight package
echo =====================================
echo Excluding: models\, models.zip, venv\, node_modules, logs, generated runtime data
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0package_lightweight.ps1"

if errorlevel 1 (
    echo ERROR: Failed to create lightweight package.
    pause
    exit /b 1
)

echo.
echo Lightweight package created successfully.
echo Copy AI-Video-App-lightweight.zip to the target machine and run launch_app.bat after extraction.
echo.
pause
exit /b 0