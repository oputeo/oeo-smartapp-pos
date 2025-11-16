@echo off
echo DEPLOYING OEO SMARTAPP TO RENDER (FREE)...
cd /d C:\Users\OPUTE\projects\OEO-SmartApp
echo.
echo [1/3] Installing deps...
call npm install
echo.
echo [2/3] Building...
call npm run build
echo.
echo [3/3] Pushing...
git add .
git commit -m "deploy: render.com - free tier"
git push
echo.
echo GO TO: https://dashboard.render.com
echo CREATE WEB SERVICE → CONNECT GITHUB → SELECT REPO
echo BUILD CMD: npm run build
echo START CMD: npm start
echo.
echo LIVE: https://oeo-smartapp-pos.onrender.com
echo.
pause