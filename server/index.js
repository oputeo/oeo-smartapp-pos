import express from 'express';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();
const PORT = process.env.PORT || 3000;

// Serve React build
app.use(express.static(path.join(__dirname, '../client/dist')));

// Health Check
app.get('/api/health', (req, res) => {
  res.json({
    status: 'OEO SmartApp LIVE',
    time: new Date().toISOString(),
    handle: '@eric_opute',
    country: 'NG'
  });
});

// SPA Fallback
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, '../client/dist/index.html'));
});

app.listen(PORT, () => {
  console.log(`OEO SmartApp LIVE on PORT ${PORT}`);
  console.log(`Visit: http://localhost:${PORT}`);
});