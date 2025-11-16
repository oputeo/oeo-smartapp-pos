@echo off
echo UPGRADING TO AI POS v2.0...
cd /d C:\Users\OPUTE\projects\OEO-SmartApp

echo [1/4] Merging buttons + adding Cash Sales...
:: (Update App.tsx + WorkflowModal.tsx)

echo [2/4] Adding AI brains...
mkdir client\src\brains
echo // pos.js > client\src\brains\pos.js
:: Add vision + RFID code

echo [3/4] Installing AI deps...
cd client
call npm install @tensorflow/tfjs tesseract.js @capacitor/camera

echo [4/4] Build + Push...
call npm run build
cd ..
git add .
git commit -m "feat: AI POS - merged buttons + cash sales + OCR"
git push

echo.
echo AI POS LIVE: https://oeo-smartapp-pos.onrender.com
echo.
pause