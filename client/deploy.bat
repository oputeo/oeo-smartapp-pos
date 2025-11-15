@echo off
echo ========================================
echo    OEO SMARTAPP — 100 PHONES LIVE
echo    @eric_opute | NG | %date% %time%
echo ========================================
echo.

:: Check if ADB is available
adb version >nul 2>&1
if %errorlevel% neq 0 (
  echo ERROR: ADB not found! Install Android Platform Tools.
  echo Download: https://developer.android.com/tools/releases/platform-tools
  pause
  exit /b 1
)

echo Scanning for connected devices...
adb devices

echo.
echo Installing OEO SmartApp on all devices...
echo.

:: APK PATH — UPDATE THIS IF NEEDED
set APK_PATH=C:\Users\OPUTE\projects\OEO-SmartApp\client\android\app\build\outputs\apk\debug\app-debug.apk

:: Check if APK exists
if not exist "%APK_PATH%" (
  echo ERROR: APK not found!
  echo Expected: %APK_PATH%
  echo Run: npm run build && npx cap build android
  pause
  exit /b 1
)

:: Install on all devices
for /f "skip=1 tokens=1" %%i in ('adb devices ^| findstr /r /v /c:"List"') do (
  if "%%i" neq "" if "%%i" neq "List" if not "%%i"=="offline" (
    echo Installing on %%i...
    adb -s %%i install -r "%APK_PATH%"
    if !errorlevel! equ 0 (
      echo SUCCESS: %%i → OEO Installed
    ) else (
      echo FAILED: %%i → Try reconnecting
    )
    echo.
  )
)

echo.
echo ========================================
echo    DEPLOYMENT COMPLETE!
echo    Total devices: Success
echo ========================================
pause