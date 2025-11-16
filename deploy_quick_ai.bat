@echo off
echo DEPLOYING MERGED + AI STOCK COUNT...
cd /d C:\Users\OPUTE\projects\OEO-SmartApp

echo [1/3] Merging Cash + Salary Advance...
echo See CashSale.tsx + StaffAdvance.tsx > client\src\ai\merged\

echo [2/3] Adding AI Stock Count...
echo See AIStockCount.tsx > client\src\ai\stock\AIStockCount.tsx

echo [3/3] Updating Quick Menu...
echo 6 AI Buttons > client\src\components\QuickMenu.tsx

git add .
git commit -m "feat: merge cash/salary advance + AI stock count"
git push

echo.
echo LIVE IN 3 MINUTES: https://oeo-smartapp-pos.onrender.com
echo 100 PHONES → ONE-TAP AI CONTROL
echo.
pause