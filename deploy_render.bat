@echo off
echo FIXING RENDER BUILD...
cd /d C:\Users\OPUTE\projects\OEO-SmartApp
echo.
echo [1/2] Installing all deps...
call npm install
cd client
call npm install
cd ..
echo.
echo [2/2] Building + Pushing...
call npm run build
git add .
git commit -m "fix: render.com - install client deps"
git push
echo.
echo GO TO RENDER DASHBOARD
echo UPDATE BUILD COMMAND:
echo npm install && cd client && npm install && npm run build
echo.
echo LIVE: https://oeo-smartapp-pos.onrender.com
echo.
pause