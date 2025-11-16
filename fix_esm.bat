@echo off
echo.
echo FIXING SERVER TO ESM - RENDER DEPLOY...
echo.
cd /d C:\Users\OPUTE\projects\OEO-SmartApp

echo Creating server/index.js (ESM)...
(
echo import express from 'express';
echo import path from 'path';
echo import { fileURLToPath } from 'url';
echo.
echo const __filename = fileURLToPath(import.meta.url);
echo const __dirname = path.dirname(__filename);
echo.
echo const app = express();
echo const PORT = process.env.PORT ^|^| 3000;
echo.
echo app.use(express.static(path.join(__dirname, '../client/dist')));
echo.
echo app.get('/api/health', (req, res) => {
echo   res.json({
echo     status: 'OEO SmartApp LIVE',
echo     time: new Date().toISOString(),
echo     handle: '@eric_opute',
echo     country: 'NG'
echo   });
echo });
echo.
echo app.get('*', (req, res) => {
echo   res.sendFile(path.join(__dirname, '../client/dist/index.html'));
echo });
echo.
echo app.listen(PORT, () => {
echo   console.log(`OEO SmartApp LIVE on PORT ${PORT}`);
echo   console.log(`Visit: http://localhost:${PORT}`);
echo });
) > server\index.js

echo.
echo Committing and pushing...
git add server/
git commit -m "fix: convert server to ESM - resolve require error"
git push

echo.
echo RENDER WILL NOW DEPLOY SUCCESSFULLY
echo LIVE URL: https://oeo-smartapp-pos.onrender.com
echo.
pause