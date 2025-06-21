@echo off
ECHO =================================================================
ECHO ==                                                             ==
ECHO ==      Warent Project Launcher (Windows)                      ==
ECHO ==                                                             ==
ECHO =================================================================
ECHO.
ECHO This script will open 3 separate terminal windows:
ECHO 1. Backend Server (uvicorn)
ECHO 2. Frontend Server (flutter)
ECHO 3. Ngrok Helper
ECHO.
ECHO After startup, you will need to manually:
ECHO 1. Run 'ngrok start --all' in the 3rd window.
ECHO 2. Copy the public URL for the backend (port 8000) from ngrok.
ECHO 3. Paste it into frontend_flutter/.env
ECHO 4. Restart the Flutter app by pressing 'R' in its window.
ECHO.
PAUSE

:: --- 1. Launch Backend ---
ECHO Launching Backend...
START "Warent Backend" cmd /k "cd backend && venv\Scripts\activate.bat && echo Backend environment activated. Starting server... && uvicorn app.main:app --reload --host 0.0.0.0"

:: --- 2. Launch Frontend ---
ECHO Launching Frontend...
START "Warent Frontend" cmd /k "cd frontend_flutter && echo Starting Flutter dev server... && flutter run -d chrome --web-port=8080 --web-hostname=0.0.0.0"

:: --- 3. Launch Ngrok Helper window ---
ECHO Launching Ngrok Helper...
ECHO Make sure you have your ngrok.yml config file ready.
START "Ngrok" cmd /k "echo Run your ngrok command here. For example: && echo ngrok start --all --config ngrok.yml"

ECHO.
ECHO All windows launched.