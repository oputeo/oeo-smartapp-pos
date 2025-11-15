Write-Host "=== Fixing Tailwind and PostCSS Config for ES Modules ==="

# 1. Remove old conflicting configs
$filesToDelete = @(
    "postcss.config.cjs",
    "postcss.config.mjs",
    "tailwind.config.cjs",
    "tailwind.config.mjs"
)

foreach ($file in $filesToDelete) {
    if (Test-Path $file) {
        Remove-Item $file -Force
        Write-Host "Removed old config: $file"
    }
}

# 2. Install Dependencies
Write-Host ""
Write-Host "Installing Tailwind and PostCSS packages..."

npm install -D tailwindcss @tailwindcss/postcss postcss autoprefixer

if ($LASTEXITCODE -ne 0) {
    Write-Host "Installation failed. Stopping script."
    exit
}

Write-Host "Packages Installed Successfully."

# 3. Create postcss.config.js
$postcssConfig = @"
export default {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
};
"@

Set-Content -Path "postcss.config.js" -Value $postcssConfig -Encoding UTF8
Write-Host "Created postcss.config.js"

# 4. Create tailwind.config.js
$tailwindConfig = @"
/** @type {import('tailwindcss').Config} */
export default {
  darkMode: 'class',
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        brand: {
          DEFAULT: '#3B82F6',
          dark: '#1E40AF',
          light: '#60A5FA',
          gold: '#D4AF37',
        },
      },
      fontFamily: {
        primary: ['Inter', 'system-ui', 'sans-serif'],
      },
      borderRadius: {
        xl: '1rem',
        '2xl': '1.5rem',
      },
      boxShadow: {
        soft: '0px 4px 12px rgba(0,0,0,0.08)',
        strong: '0px 6px 20px rgba(0,0,0,0.15)',
      },
    },
  },
  plugins: [],
}
"@

Set-Content -Path "tailwind.config.js" -Value $tailwindConfig -Encoding UTF8
Write-Host "Created tailwind.config.js with Dark Mode and Custom Theme"

# 5. Ensure index.css exists and has Tailwind directives
$cssPath = "src\index.css"

if (!(Test-Path $cssPath)) {
$cssContent = @"
@tailwind base;
@tailwind components;
@tailwind utilities;

/* Custom Scrollbar */
::-webkit-scrollbar {
  width: 6px;
}
::-webkit-scrollbar-thumb {
  background: #3B82F6;
  border-radius: 8px;
}
"@
Set-Content $cssPath -Encoding UTF8 -Value $cssContent
Write-Host "index.css created with Tailwind directives"
} else {
Write-Host "index.css already exists. Ensure it contains Tailwind directives."
}

Write-Host ""
Write-Host "=== Fix Complete! Launching Vite Dev Server ==="
npm run dev
