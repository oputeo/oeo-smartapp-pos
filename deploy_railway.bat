@echo off
echo DEPLOYING OEO SMARTAPP TO RAILWAY...
cd /d C:\Users\OPUTE\projects\OEO-SmartApp
npm run build
git add .
git commit -m "deploy: %date% %time%"
git push
echo.
echo LIVE SOON: https://oeo-smartapp.up.railway.app
echo.
pause