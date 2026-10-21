@echo off
setlocal EnableExtensions
title AI Video App - Launcher
cd /d "%~dp0"


REM Ensure optional model root exists; app can still run without downloaded models.
if not exist models mkdir models
if not exist venv\Scripts\activate (
    echo Virtual environment not found. Running setup first...
    call setup.bat
    if errorlevel 1 exit /b 1
)

call venv\Scripts\activate

echo Starting backend...
start "Backend" cmd /k "call venv\Scripts\activate && python -m uvicorn backend.main:app --host 127.0.0.1 --port 8000"

echo Starting frontend...
where npm.cmd >nul 2>&1
if errorlevel 1 (
    echo npm not found. Frontend dev server skipped.
    echo If frontend\dist exists, use http://127.0.0.1:8000/app after backend starts.
    start "" "http://127.0.0.1:8000/app"
) else (
    if exist frontend\package.json (
        cd frontend
        if not exist node_modules (
            echo Installing frontend dependencies...
            call npm install
        )
        start "Frontend" cmd /k "npm run dev"
        cd ..
        start "" "http://localhost:5173"
    ) else (
        echo frontend\package.json not found. Opening backend API docs.
        start "" "http://127.0.0.1:8000/docs"
    )
)

echo App launched!
