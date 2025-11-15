# ================================
#  Tailwind + Vite Auto Setup Script
#  Works for Windows PowerShell
#  Author: ChatGPT (GPT-5)
# ================================

Write-Host "🚀 Starting Tailwind Setup..." -ForegroundColor Cyan

# Set your project path
$projectPath = "C:\Users\OPUTE\projects\OEO-SmartApp\client"

if (!(Test-Path $projectPath)) {
    Write-Host "❌ Project path not found: $projectPath" -ForegroundColor Red
    exit
}

Set-Location $projectPath
Write-Host "📍 Project located: $projectPath" -ForegroundColor Green

# Check Node & npm
Write-Host "🔍 Checking Node & npm versions..."
node -v
npm -v

# Clean npm cache
Write-Host "🧹 Cleaning npm cache..."
npm cache clean --force

# Install Tailwind & dependencies
Write-Host "📦 Installing TailwindCSS + PostCSS + Autoprefixer..."
npm install -D tailwindcss postcss autoprefixer

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to install packages. Check logs." -ForegroundColor Red
    exit
}

# Initialize Tailwind
Write-Host "⚙️ Initializing Tailwind config..."
npx tailwindcss init -p

# Patch tailwind.config.js
$tailwindConfig = Join-Path $projectPath "tailwind.config.js"
(Get-Content $tailwindConfig) -replace "content: \[\]", "content: [`./index.html`, `./src/**/*.{js,jsx,ts,tsx}`]" | Set-Content $tailwindConfig

Write-Host "✅ Updated tailwind.config.js"

# Update index.css
$indexCssPath = Join-Path $projectPath "src\index.css"
if (Test-Path $indexCssPath) {
    Set-Content -Path $indexCssPath -Value "@tailwind base;`n@tailwind components;`n@tailwind utilities;"
    Write-Host "✅ index.css Tailwind directives added"
} else {
    Write-Host "⚠️ index.css not found — creating it..."
    New-Item -Path $indexCssPath -ItemType File -Force | Out-Null
    Set-Content -Path $indexCssPath -Value "@tailwind base;`n@tailwind components;`n@tailwind utilities;"
}

# Install dependencies from package.json
Write-Host "🧩 Running npm install..."
npm install

Write-Host "`n🔥 Tailwind successfully installed & configured!"
Write-Host "▶️ Starting Vite Dev Server..."
npm run dev
