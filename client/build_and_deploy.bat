@echo off
echo BUILDING OEO SMARTAPP...
npm run build && npx cap copy android && npx cap build android

if %errorlevel% neq 0 (
  echo BUILD FAILED!
  pause
  exit /b 1
)

echo BUILD SUCCESS! Starting deployment...
call deploy.bat