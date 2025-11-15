# === OEO SmartApp Enterprise Setup (ZERO COST) ===
# Run in: C:\Users\OPUTE\projects\OEO-SmartApp\client

$ErrorActionPreference = "Stop"

Write-Host "Enterprise setup (OPTIMIZED + FIXED) starting..." -ForegroundColor Green

# === SET CORRECT WORKING DIRECTORY ===
$ProjectRoot = $PSScriptRoot
Set-Location $ProjectRoot
Write-Host "Working in: $ProjectRoot" -ForegroundColor Cyan

# === BACKUP EXISTING FILES ===
$FilesToBackup = @("postcss.config.js", "tailwind.config.cjs", "src/index.css", "vite.config.js", "index.html", "src/main.tsx")
foreach ($file in $FilesToBackup) {
    $path = Join-Path $ProjectRoot $file
    if (Test-Path $path) {
        $backup = "$path.bak"
        Copy-Item $path $backup -Force
        Write-Host "BACKED UP: $file -> $file.bak" -ForegroundColor Yellow
    }
}

# === INSTALL DEPENDENCIES (FIXED) ===
Write-Host "Installing core dependencies..." -ForegroundColor Green
npm install tailwindcss postcss autoprefixer daisyui @shadcn/ui framer-motion lucide-react recharts xlsx file-saver jsqr @capacitor/core @capacitor/cli

Write-Host "Installing ESC/POS printer (GitHub)..." -ForegroundColor Green
npm install https://github.com/ahmadfauziridwan/capacitor-esc-pos-printer.git

# === WRITE postcss.config.js ===
$PostCss = @"
module.exports = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
"@
$PostCssPath = Join-Path $ProjectRoot "postcss.config.js"
[System.IO.File]::WriteAllText($PostCssPath, $PostCss)
Write-Host "WROTE: postcss.config.js" -ForegroundColor Green

# === WRITE tailwind.config.cjs ===
$TailwindConfig = @"
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: '#1e40af',   // ZA Blue
        accent: '#f59e0b',    // Gold
      },
    },
  },
  plugins: [require('daisyui')],
  daisyui: {
    themes: ["light", "dark"],
  },
}
"@
$TailwindPath = Join-Path $ProjectRoot "tailwind.config.cjs"
[System.IO.File]::WriteAllText($TailwindPath, $TailwindConfig)
Write-Host "WROTE: tailwind.config.cjs" -ForegroundColor Green

# === WRITE vite.config.ts ===
$ViteConfig = @"
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    port: 5173,
    open: true
  }
})
"@
$VitePath = Join-Path $ProjectRoot "vite.config.ts"
[System.IO.File]::WriteAllText($VitePath, $ViteConfig)
Write-Host "WROTE: vite.config.ts" -ForegroundColor Green

# === WRITE index.html ===
$IndexHtml = @"
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <link rel="icon" type="image/svg+xml" href="/vite.svg" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>OEO SmartApp</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.tsx"></script>
  </body>
</html>
"@
$HtmlPath = Join-Path $ProjectRoot "index.html"
[System.IO.File]::WriteAllText($HtmlPath, $IndexHtml)
Write-Host "WROTE: index.html" -ForegroundColor Green

# === WRITE src/index.css ===
$IndexCss = @"
@tailwind base;
@tailwind components;
@tailwind utilities;

body {
  margin: 0;
  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
  background: #f3f4f6;
}

.dark {
  background: #111827;
  color: #f3f4f6;
}
"@
$IndexCssDir = Join-Path $ProjectRoot "src"
if (!(Test-Path $IndexCssDir)) {
    New-Item -ItemType Directory -Path $IndexCssDir -Force
}
$IndexCssPath = Join-Path $IndexCssDir "index.css"
[System.IO.File]::WriteAllText($IndexCssPath, $IndexCss)
Write-Host "WROTE: src/index.css" -ForegroundColor Green

# === WRITE src/main.tsx ===
$MainTsx = @"
import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App.tsx'
import './index.css'

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
)
"@
$MainPath = Join-Path $IndexCssDir "main.tsx"
[System.IO.File]::WriteAllText($MainPath, $MainTsx)
Write-Host "WROTE: src/main.tsx" -ForegroundColor Green

# === DONE ===
Write-Host "`nOEO SMARTAPP ENTERPRISE SETUP COMPLETE!" -ForegroundColor Green
Write-Host "Run: npm run dev" -ForegroundColor Cyan
Write-Host "Then: npx cap init && npx cap add android" -ForegroundColor Cyan
