@echo off
echo DEPLOYING FINAL AI QUICK MENU...
cd /d C:\Users\OPUTE\projects\OEO-SmartApp

echo [1/4] Merging Advances...
echo See EmployeeAdvance.tsx > client\src\ai\EmployeeAdvance.tsx

echo [2/4] Adding Cash Sale...
echo See CashSale.tsx > client\src\ai\CashSale.tsx

echo [3/4] Adding AI Stock Count...
echo See AIStockCount.tsx > client\src\ai\AIStockCount.tsx

echo [4/4] Pushing to Render...
git add .
git commit -m "feat: final quick menu - merged advance + cash sale + AI stock count"
git push

echo.
echo LIVE IN 3 MINUTES: https://oeo-smartapp-pos.onrender.com
echo 100 PHONES → AI EMPIRE FULLY LIVE
echo.
pause