@echo off
:: ========================================
::  OEO SMARTAPP - ANDROID BUILD SCRIPT
::  @eric_opute | NOV 15, 2025
:: ========================================
echo.
echo    OOOOOOO  EEEEEEE  OOOOOOO
echo   O      O E       O      O
echo   O      O EEEEE   O      O
echo   O      O E       O      O
echo    OOOOOOO  EEEEEEE  OOOOOOO
echo.
echo    @eric_opute ^| %date% %time%
echo ========================================
echo.

echo [1/5] Building web app...
call npm run build
if %errorlevel% neq 0 (
  echo [ERROR] Web build failed!
  pause
  exit /b 1
)
echo [SUCCESS] Web build complete

echo.
echo [2/5] Installing Capacitor CLI...
cd client
call npm install @capacitor/cli @capacitor/core --save-dev
echo [SUCCESS] Capacitor ready

echo.
echo [3/5] Copying to Android...
call npx cap copy android
if %errorlevel% neq 0 (
  echo [ERROR] Copy failed!
  pause
  exit /b 1
)
echo [SUCCESS] Assets copied

echo.
echo [4/5] Opening Android Studio...
call npx cap open android
echo.
echo [5/5] NEXT STEPS:
echo    1. Wait for Gradle sync
echo    2. Build -^> Build APK(s)
echo    3. Click "locate"
echo    4. APK: android/app/build/outputs/apk/debug/app-debug.apk
echo    5. Run: deploy.bat -^> 100 PHONES
echo.
echo ========================================
echo    BUILD COMPLETE
echo ========================================
pause