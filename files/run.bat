@echo off
setlocal EnableExtensions EnableDelayedExpansion
title AI Video App - Run
cd /d "%~dp0"


REM Ensure optional model root exists; app can still run without downloaded models.
if not exist models mkdir models
echo Starting AI Video App...
echo Logs will be written in this folder: %CD%

if not exist venv\Scripts\activate (
  echo Virtual environment not found. Please run setup.bat first.
  pause
  exit /b 1
)

if not exist backend\main.py (
  echo backend\main.py not found.
  echo Copy your backend folder into AI-Video-App\backend and try again.
  pause
  exit /b 1
)

call venv\Scripts\activate

if not exist requirements.txt (
  echo.
  echo ERROR: requirements.txt not found in this folder.
  echo Current folder: %CD%
  echo.
  echo Expected files in AI-Video-App root:
  echo   - requirements.txt
  echo   - download_model.py
  echo   - setup.bat
  echo   - run.bat
  echo   - backend\main.py
  echo.
  echo This usually means an incomplete package was copied ^(e.g. only dist/output^).
  echo Re-copy/extract the FULL AI-Video-App folder and run launch_app.bat.
  pause
  exit /b 1
)

python -c "import uvicorn" >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
  echo Installing missing backend dependencies...
  python -m pip install -r requirements.txt
)

echo Manual image mode is the default. AI image model is optional and lazy-loaded only when USE_AI_IMAGE_GENERATION=true.

:: Start backend server (no reload in packaged launcher)
start "Backend" /min cmd /c "call venv\Scripts\activate && python -m uvicorn backend.main:app --host 127.0.0.1 --port 8000 --reload > backend.log 2>&1"

:: Wait for backend and verify it is reachable
set "BACKEND_OK=0"
timeout /t 6 /nobreak >nul
python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8000/docs', timeout=5)" >nul 2>&1
if %ERRORLEVEL% EQU 0 set "BACKEND_OK=1"

if "%BACKEND_OK%"=="0" (
  echo.
  echo Backend did not become reachable on http://127.0.0.1:8000
  echo Check backend.log in this folder for crash details.
  start "" notepad backend.log
)

:: Runtime must not depend on npm. Default to backend-served static app.
set "OPEN_URL=http://127.0.0.1:8000/app"
set "NPM_OK=0"
set "FRONTEND_OK=0"
set "FRONTEND_LOG=%CD%\frontend.log"
echo [%date% %time%] Starting run.bat > "%FRONTEND_LOG%"

if not exist frontend\dist\index.html (
  echo ERROR: FRONTEND BUILD MISSING - REPACKAGE REQUIRED
  echo ERROR: FRONTEND BUILD MISSING - REPACKAGE REQUIRED >> "%FRONTEND_LOG%"
  exit /b 1
)

:: Optional dev mode only when explicitly requested.
if /I "%APP_DEV_MODE%"=="1" if exist frontend\package.json (
  echo frontend\package.json found >> "%FRONTEND_LOG%"
  where npm.cmd >nul 2>&1 && set "NPM_OK=1"
  if "!NPM_OK!"=="0" if exist "%ProgramFiles%\nodejs\npm.cmd" set "NPM_OK=1"
  if "!NPM_OK!"=="0" if exist "%ProgramFiles(x86)%\nodejs\npm.cmd" set "NPM_OK=1"
  if "!NPM_OK!"=="1" (
    echo npm detected >> "%FRONTEND_LOG%"
  ) else (
    echo npm NOT detected >> "%FRONTEND_LOG%"
  )

  if "!NPM_OK!"=="1" (
    if not exist frontend\node_modules (
      echo Frontend dependencies not found. Installing with npm...
      call cmd /c "cd /d frontend && npm install"
    )
    echo Frontend package found. Starting Vite dev server on port 5173...
    start "Frontend" /min cmd /c "cd /d frontend && npm run dev >> ""%FRONTEND_LOG%"" 2>&1"

    for /l %%i in (1,1,30) do (
      python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:5173', timeout=2)" >nul 2>&1
      if !ERRORLEVEL! EQU 0 (
        set "FRONTEND_OK=1"
        goto :frontend_ready
      )
      timeout /t 1 /nobreak >nul
    )
    :frontend_ready
    if "!FRONTEND_OK!"=="1" (
      set "OPEN_URL=http://localhost:5173"
    ) else (
      echo Frontend dev server not reachable on 5173.
      echo Check frontend.log in this folder for npm/vite errors.
      start "" notepad frontend.log
    )
  ) else (
    echo npm not found. Dev server skipped; using static app on /app.
    echo npm not found. Dev server skipped; using static app on /app. >> "%FRONTEND_LOG%"
  )
)

if "%FRONTEND_OK%"=="1" (
  set "OPEN_URL=http://localhost:5173"
) else (
  echo Falling back to backend static app URL: http://127.0.0.1:8000/app
)

:: Open UI
echo Opening browser: %OPEN_URL%
call :open_url "%OPEN_URL%"
echo If browser does not open automatically, open this URL manually:
echo   %OPEN_URL%
goto :eof

:open_url
set "TARGET_URL=%~1"
start "" "%TARGET_URL%" >nul 2>&1
if %ERRORLEVEL% EQU 0 goto :eof

powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process '%TARGET_URL%'" >nul 2>&1
if %ERRORLEVEL% EQU 0 goto :eof

if exist "%ProgramFiles%\Google\Chrome\Application\chrome.exe" (
  start "" "%ProgramFiles%\Google\Chrome\Application\chrome.exe" "%TARGET_URL%" >nul 2>&1
  if %ERRORLEVEL% EQU 0 goto :eof
)
if exist "%ProgramFiles(x86)%\Microsoft\Edge\Application\msedge.exe" (
  start "" "%ProgramFiles(x86)%\Microsoft\Edge\Application\msedge.exe" "%TARGET_URL%" >nul 2>&1
  if %ERRORLEVEL% EQU 0 goto :eof
)
if exist "%ProgramFiles%\Microsoft\Edge\Application\msedge.exe" (
  start "" "%ProgramFiles%\Microsoft\Edge\Application\msedge.exe" "%TARGET_URL%" >nul 2>&1
)
