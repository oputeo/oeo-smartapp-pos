@echo off
echo UPGRADING TO AI SUPERMARKET POS...
cd /d C:\Users\OPUTE\projects\OEO-SmartApp
echo.
echo [1/5] Creating AI brains...
mkdir client\src\brains
mkdir server\brains
mkdir public\models

echo [2/5] Adding AI files...
:: (Paste pos.js, inventory.js, etc. via echo > file)

echo [3/5] Installing AI deps...
cd client
call npm install @tensorflow/tfjs tesseract.js pdfjs-dist
cd ..

echo [4/5] Building...
call npm run build

echo [5/5] Pushing...
git add .
git commit -m "feat: AI POS - 4 brains + audit"
git push

echo.
echo AI POS LIVE: https://oeo-smartapp-pos.onrender.com
echo.
pause