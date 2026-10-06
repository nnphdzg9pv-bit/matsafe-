@echo off
REM ============================================================================
REM  Lanceur MatSafe (Windows)
REM  Ouvre MatSafe Fighter et MatSafe Club sous la MEME adresse locale
REM  (http://localhost) pour que la communication entre les deux applications
REM  fonctionne.
REM ============================================================================
cd /d "%~dp0"
set PORT=8000

where python >nul 2>nul
if %errorlevel%==0 (
  set PY=python
) else (
  where py >nul 2>nul
  if %errorlevel%==0 (
    set PY=py
  ) else (
    echo.
    echo   Python n'est pas installe sur cet ordinateur.
    echo   Installez-le gratuitement depuis : https://www.python.org/downloads/
    echo   ^(cochez "Add Python to PATH" pendant l'installation^) puis relancez ce fichier.
    echo.
    pause
    exit /b 1
  )
)

echo.
echo   MatSafe demarre...
start "MatSafe (serveur local)" %PY% -m http.server %PORT%
timeout /t 2 >nul

start "" "http://localhost:%PORT%/MatSafe-Fighter-v1.html"
start "" "http://localhost:%PORT%/MatSafe-Club-v1.html"

echo.
echo   MatSafe est lance :
echo       Fighter : http://localhost:%PORT%/MatSafe-Fighter-v1.html
echo       Club    : http://localhost:%PORT%/MatSafe-Club-v1.html
echo.
echo   Gardez la fenetre "MatSafe (serveur local)" OUVERTE pendant l'utilisation.
echo   Fermez-la pour arreter MatSafe.
echo.
pause
