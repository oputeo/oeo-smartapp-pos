# setup-full-ui-ts.ps1
# Advanced Tailwind + DaisyUI + shadcn-ui setup for React + Vite (TypeScript)
# Safe for Windows PowerShell (no emojis, no stray & characters)

$projectRoot = "C:\Users\OPUTE\projects\OEO-SmartApp\client"
$srcRoot = Join-Path $projectRoot "src"
$componentsDir = Join-Path $srcRoot "components"
$pagesDir = Join-Path $srcRoot "pages"
$themeTogglePath = Join-Path $componentsDir "ThemeToggle.tsx"
$indexCssPath = Join-Path $srcRoot "index.css"
$tailwindConfigPath = Join-Path $projectRoot "tailwind.config.js"
$postcssConfigPath = Join-Path $projectRoot "postcss.config.js"
$tsconfigPath = Join-Path $projectRoot "tsconfig.json"
$packageJsonPath = Join-Path $projectRoot "package.json"

function Abort($msg) {
    Write-Host "ERROR: $msg" -ForegroundColor Red
    exit 1
}

Write-Host "Starting full UI setup (TypeScript + Tailwind + DaisyUI + shadcn-ui)..." -ForegroundColor Cyan

if (-not (Test-Path $projectRoot)) {
    Abort "Project root not found: $projectRoot"
}

Set-Location $projectRoot
Write-Host "Working directory: $projectRoot"

# Ensure package.json exists
if (-not (Test-Path $packageJsonPath)) {
    Abort "package.json not found in project root. Run this script from the Vite React project root."
}

# Check node & npm
Write-Host "Checking node and npm..."
try {
    $nodeVer = (& node -v) 2>$null
    $npmVer = (& npm -v) 2>$null
    if (-not $nodeVer -or -not $npmVer) {
        Abort "node or npm not found. Install Node.js LTS and try again."
    }
    Write-Host "Node version: $nodeVer"
    Write-Host "npm version: $npmVer"
} catch {
    Abort "Failed to run node or npm. Ensure Node.js is installed."
}

# Create src, components, pages folders if missing
if (-not (Test-Path $srcRoot)) {
    New-Item -Path $srcRoot -ItemType Directory -Force | Out-Null
    Write-Host "Created src folder at $srcRoot"
}
if (-not (Test-Path $componentsDir)) {
    New-Item -Path $componentsDir -ItemType Directory -Force | Out-Null
    Write-Host "Created components folder at $componentsDir"
}
if (-not (Test-Path $pagesDir)) {
    New-Item -Path $pagesDir -ItemType Directory -Force | Out-Null
    Write-Host "Created pages folder at $pagesDir"
}

# Install dependencies (dev and regular)
Write-Host "Installing dependencies (this may take a minute)..."
# dev dependencies: tailwindcss, postcss, autoprefixer, daisyui, typescript, @types/react, @types/react-dom
npm install -D tailwindcss postcss autoprefixer daisyui typescript @types/react @types/react-dom | Out-Null
if ($LASTEXITCODE -ne 0) {
    Abort "Failed to install dev dependencies. Check network and npm logs."
}

# Add shadcn-ui tooling (best-effort)
Write-Host "Installing shadcn-ui dev tool (best-effort). This may be non-interactive."
# Attempt to install the shadcn CLI as a devDependency
npm install -D @shadcn/ui shadcn-ui | Out-Null
# No hard-fail here because shadcn tooling can vary by version

# Initialize Tailwind config and postcss (creates files if missing)
Write-Host "Initializing Tailwind configuration..."
npx tailwindcss init -p | Out-Null

# Backup existing tailwind.config.js if present
if (Test-Path $tailwindConfigPath) {
    $bak = $tailwindConfigPath + ".backup." + (Get-Date -Format "yyyyMMddHHmmss")
    Copy-Item -Path $tailwindConfigPath -Destination $bak -Force
    Write-Host "Backed up existing tailwind.config.js to $bak"
}

# Write a safe tailwind.config.js (darkMode: 'class', DaisyUI)
$tailwindConfigContent = @'
/** @type {import("tailwindcss").Config} */
module.exports = {
  darkMode: "class",
  content: [
    "./index.html",
    "./src/**/*.{js,jsx,ts,tsx}"
  ],
  theme: {
    extend: {}
  },
  plugins: [
    require("daisyui")
  ],
  daisyui: {
    themes: [
      {
        light: {
          "primary": "#bfa14a",
          "secondary": "#f8e9a1",
          "accent": "#ffd166",
          "neutral": "#111827",
          "base-100": "#ffffff",
          "info": "#3abff8",
          "success": "#36d399",
          "warning": "#fbbd23",
          "error": "#ef4444"
        }
      },
      "dark"
    ],
    darkTheme: "dark",
    base: true
  }
}
'@
Set-Content -Path $tailwindConfigPath -Value $tailwindConfigContent -Encoding UTF8
Write-Host "Wrote tailwind.config.js"

# Ensure postcss.config.js
$postcssContent = @'
module.exports = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  }
}
'@
Set-Content -Path $postcssConfigPath -Value $postcssContent -Encoding UTF8
Write-Host "Wrote postcss.config.js"

# Create or replace src/index.css with Tailwind directives and base styles (Light default)
$indexCssContent = @'
@tailwind base;
@tailwind components;
@tailwind utilities;

/* Light mode default variables */
:root {
  --brand: #bfa14a;
  --brand-contrast: #000000;
}

/* Page defaults */
body {
  @apply antialiased;
  font-family: Inter, system-ui, -apple-system, "Segoe UI", Roboto, "Helvetica Neue", Arial;
  background-color: white;
  color: #111827;
}

/* Dark theme fallback */
.dark body {
  background-color: #0f172a;
  color: #f8fafc;
}
'@
Set-Content -Path $indexCssPath -Value $indexCssContent -Encoding UTF8
Write-Host "Wrote src/index.css"

# Ensure TypeScript is configured: create tsconfig.json if missing
if (-not (Test-Path $tsconfigPath)) {
    $tsconfigContent = @'
{
  "compilerOptions": {
    "target": "ES2021",
    "useDefineForClassFields": true,
    "lib": ["DOM", "ES2021"],
    "allowJs": true,
    "skipLibCheck": true,
    "esModuleInterop": true,
    "allowSyntheticDefaultImports": true,
    "strict": false,
    "forceConsistentCasingInFileNames": true,
    "module": "ESNext",
    "moduleResolution": "Bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx"
  },
  "include": ["src"]
}
'@
    Set-Content -Path $tsconfigPath -Value $tsconfigContent -Encoding UTF8
    Write-Host "Created tsconfig.json"
} else {
    Write-Host "tsconfig.json already exists, leaving it intact."
}

# Create ThemeToggle.tsx (TypeScript) in components
$themeToggleContent = @'
import React, { useEffect, useState } from "react";

export default function ThemeToggle(): JSX.Element {
  const [dark, setDark] = useState(false);

  useEffect(() => {
    try {
      const saved = localStorage.getItem("theme");
      if (saved === "dark") {
        document.documentElement.classList.add("dark");
        setDark(true);
      } else {
        document.documentElement.classList.remove("dark");
        setDark(false);
      }
    } catch {
      // ignore
    }
  }, []);

  function toggle(): void {
    const willDark = !dark;
    setDark(willDark);
    if (willDark) {
      document.documentElement.classList.add("dark");
      try { localStorage.setItem("theme", "dark") } catch {}
    } else {
      document.documentElement.classList.remove("dark");
      try { localStorage.setItem("theme", "light") } catch {}
    }
  }

  return (
    <button onClick={toggle} aria-label="Toggle theme" className="px-3 py-1 rounded border">
      {dark ? "Switch to Light" : "Switch to Dark"}
    </button>
  );
}
'@
Set-Content -Path $themeTogglePath -Value $themeToggleContent -Encoding UTF8
Write-Host "Created ThemeToggle.tsx at $themeTogglePath"

# Create a sample UI page in TypeScript to validate setup
$samplePagePath = Join-Path $pagesDir "UiSample.tsx"
$samplePageContent = @'
import React from "react";
import ThemeToggle from "../components/ThemeToggle";

export default function UiSample(): JSX.Element {
  return (
    <div className="p-6">
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-2xl font-bold">UI Sample</h1>
        <ThemeToggle />
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div className="card p-4 bg-white border rounded shadow">
          <h2 className="font-semibold mb-2">Card</h2>
          <p>Example card using Tailwind and DaisyUI theme colors.</p>
        </div>

        <div className="p-4 border rounded shadow bg-white">
          <button className="btn btn-primary">Primary Button</button>
        </div>
      </div>
    </div>
  );
}
'@
Set-Content -Path $samplePagePath -Value $samplePageContent -Encoding UTF8
Write-Host "Created sample UI page at $samplePagePath"

# Try to detect main entry file and import the index.css if missing
$possibleMain = @("main.tsx","main.ts","main.jsx","main.js","index.tsx","index.jsx")
$foundMain = $null
foreach ($m in $possibleMain) {
    $p = Join-Path $srcRoot $m
    if (Test-Path $p) {
        $foundMain = $p
        break
    }
}

if ($foundMain) {
    Write-Host "Found app entry: $foundMain"
    $mainText = Get-Content $foundMain -Raw
    if ($mainText -notmatch "index.css") {
        # import index.css at top
        $newMain = "import ""./index.css"";" + "`n" + $mainText
        # backup
        $bakMain = $foundMain + ".backup." + (Get-Date -Format "yyyyMMddHHmmss")
        Set-Content -Path $bakMain -Value $mainText -Encoding UTF8
        Set-Content -Path $foundMain -Value $newMain -Encoding UTF8
        Write-Host "Prepended import for index.css into $foundMain and backed up original to $bakMain"
    } else {
        Write-Host "index.css import already present in $foundMain"
    }
} else {
    Write-Host "Could not find main entry file in src. Please ensure you import src/index.css manually."
}

# Ensure package.json has dev script
$pkgRaw = Get-Content $packageJsonPath -Raw
try {
    $pkg = $pkgRaw | ConvertFrom-Json
} catch {
    Abort "Could not parse package.json. Aborting."
}

if ($pkg.scripts -and $pkg.scripts.dev) {
    Write-Host "package.json already has a dev script."
} else {
    if (-not $pkg.scripts) { $pkg.scripts = @{} }
    $pkg.scripts.dev = "vite"
    $pkg | ConvertTo-Json -Depth 10 | Set-Content -Path $packageJsonPath -Encoding UTF8
    Write-Host "Added dev script to package.json"
}

# Run final npm install and start dev server
Write-Host "Running npm install to finalize packages..."
npm install | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "npm install returned non-zero exit code. Please inspect npm logs."
}

Write-Host "Starting dev server using npm run dev..."
Start-Process -FilePath "npm" -ArgumentList "run","dev" -NoNewWindow

Write-Host "Setup script finished. Open the dev server URL shown in the console. If you cannot see the UI sample, open /src/pages/UiSample.tsx and import it into your App or a route."
