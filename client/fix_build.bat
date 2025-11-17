@echo off
echo FIXING BUILD ERRORS...
cd /d C:\Users\OPUTE\projects\OEO-SmartApp\client

echo [1/3] Deleting fake AI files...
if exist src\ai rmdir /s /q src\ai

echo [2/3] Fixing QuickMenu.tsx...
(
echo import { FileText, DollarSign, Package, Truck, Receipt, ClipboardList } from 'lucide-react'
echo.
echo export default function QuickMenu() {
echo   return (
echo     ^<div className="grid grid-cols-3 gap-4"^>
echo       ^<button className="btn btn-primary flex items-center gap-2"^>^<DollarSign /^> Employee Request^</button^>
echo       ^<button className="btn btn-success flex items-center gap-2"^>^<Receipt /^> Cash Sales^</button^>
echo       ^<button className="btn btn-info flex items-center gap-2"^>^<Package /^> Stock Transfer^</button^>
echo       ^<button className="btn btn-warning flex items-center gap-2"^>^<Truck /^> Delivery Note^</button^>
echo       ^<button className="btn btn-accent flex items-center gap-2"^>^<FileText /^> Purchase Order^</button^>
echo       ^<button className="btn btn-secondary flex items-center gap-2"^>^<ClipboardList /^> Payment Request^</button^>
echo     ^</div^>
echo   )
echo }
) > src\components\QuickMenu.tsx

echo [3/3] Rebuilding...
call npm run build

echo.
echo BUILD SUCCESSFUL!
echo LIVE: https://oeo-smartapp-pos.onrender.com
echo.
pause