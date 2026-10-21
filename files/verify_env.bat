@echo off
setlocal EnableExtensions
cd /d "%~dp0"

set "HAS_ERROR=0"
echo ========================================
echo AI Video App - Environment Verification
echo ========================================

where python >nul 2>&1
if errorlevel 1 (
  echo [ERROR] Python not found in PATH.
  set "HAS_ERROR=1"
) else (
  echo [OK] Python found.
)

python -m pip --version >nul 2>&1
if errorlevel 1 (
  echo [ERROR] pip not working via python -m pip.
  set "HAS_ERROR=1"
) else (
  echo [OK] pip working.
)

where node >nul 2>&1
if errorlevel 1 (
  echo [ERROR] Node.js not found in PATH.
) else (
  echo [OK] Node.js found.
)

where npm.cmd >nul 2>&1
if errorlevel 1 (
  echo [ERROR] npm not found in PATH.
) else (
  echo [OK] npm found.
)

where redis-server >nul 2>&1
if errorlevel 1 (
  echo [WARN] redis-server not found in PATH ^(required only if your workflow uses Redis queue^).
) else (
  echo [OK] redis-server found.
)

where ffmpeg >nul 2>&1
if errorlevel 1 (
  echo [WARN] ffmpeg not found in PATH ^(moviepy/imageio_ffmpeg may still work via Python wheel^).
) else (
  echo [OK] ffmpeg found.
)

if exist "frontend\dist\index.html" (
  echo [OK] frontend\dist\index.html present.
) else (
  echo [ERROR] frontend\dist\index.html missing.
  set "HAS_ERROR=1"
)

if exist "backend\main.py" (
  echo [OK] backend entry file present ^(backend\main.py^).
) else (
  echo [ERROR] backend\main.py missing.
  set "HAS_ERROR=1"
)

if exist "requirements-core.txt" (
  echo [OK] requirements-core.txt present.
) else (
  echo [ERROR] requirements-core.txt missing.
  set "HAS_ERROR=1"
)

echo ----------------------------------------
if "%HAS_ERROR%"=="1" (
  echo VERIFICATION FAILED - fix errors above.
  exit /b 1
) else (
  echo VERIFICATION PASSED.
  exit /b 0
)
