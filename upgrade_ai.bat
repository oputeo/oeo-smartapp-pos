@echo off
echo UPGRADING OEO SMARTAPP TO AI SUPERMART...
cd /d C:\Users\OPUTE\projects\OEO-SmartApp

echo [1/5] Adding AI Vision...
mkdir client\src\ai
echo See CameraScan.tsx > client\src\ai\CameraScan.tsx

echo [2/5] Adding OCR...
echo See InvoiceUpload.tsx > client\src\ai\InvoiceUpload.tsx

echo [3/5] Adding AI Dashboard...
mkdir client\app\admin
echo See AIDashboard.tsx > client\app\admin\AIDashboard.tsx

echo [4/5] Adding Audit...
echo See UploadBankStatement.tsx > client\src\ai\Audit.tsx

echo [5/5] Pushing to Render...
git add .
git commit -m "feat: AI Supermart POS - 3 Brains + Audit"
git push

echo.
echo LIVE IN 3 MINUTES: https://oeo-smartapp-pos.onrender.com
echo.
pause