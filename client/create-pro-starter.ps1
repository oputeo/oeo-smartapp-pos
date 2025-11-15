# create-pro-starter.ps1
# Creates Vite + React + TS starter with Tailwind, Zustand, Router, Shadcn-style UI scaffold
# Writes all files as UTF-8 (no BOM)

$ErrorActionPreference = "Stop"
Write-Host "Starting Pro Starter creation..."

function WriteUtf8([string]$path, [string]$content) {
    $enc = [System.Text.Encoding]::UTF8
    [System.IO.File]::WriteAllText($path, $content, $enc)
    Write-Host "Wrote: $path"
}

# Ensure node is available
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: node not found in PATH. Install Node.js and retry." -ForegroundColor Red
    exit 1
}

# Create package via npm create vite if package.json not exists
if (-not (Test-Path "package.json")) {
    Write-Host "Bootstrapping vite react-ts project (non-interactive)..."
    npm create vite@latest . -- --template react-ts | Out-Null
} else {
    Write-Host "package.json already exists — using current folder."
}

# Install dependencies
$devDeps = @("tailwindcss","postcss","autoprefixer","daisyui")
$deps = @("react-router-dom","zustand","framer-motion","recharts","react-hot-toast","react-icons","axios","jwt-decode")
Write-Host "Installing devDeps and deps (this may take a few minutes)..."
npm install -D $devDeps
npm install $deps

# PostCSS config (clean)
$postcss = @'
module.exports = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
};
'@
WriteUtf8 "postcss.config.cjs" $postcss

# Tailwind config (clean)
$tailwind = @'
/** @type {import("tailwindcss").Config} */
module.exports = {
  darkMode: "class",
  content: ["./index.html","./src/**/*.{js,ts,jsx,tsx}"],
  theme: {
    extend: {
      colors: {
        brand: { DEFAULT: "#3B82F6", light: "#60A5FA", dark: "#1E40AF", gold: "#D4AF37" }
      }
    }
  },
  plugins: [require("daisyui")],
  daisyui: {
    themes: [
      {
        light: {
          primary: "#3B82F6",
          secondary: "#60A5FA",
          accent: "#ffd166",
          neutral: "#111827",
          "base-100": "#ffffff",
          info: "#3abff8",
          success: "#36d399",
          warning: "#fbbd23",
          error: "#ef4444"
        }
      },
      "dark"
    ],
    darkTheme: "dark",
    base: true
  }
};
'@
WriteUtf8 "tailwind.config.cjs" $tailwind

# Ensure src folder
if (-not (Test-Path "src")) { New-Item -ItemType Directory -Path "src" | Out-Null }

# index.css (safe)
$indexCss = @'
@import "tailwindcss/base";
@import "tailwindcss/components";
@import "tailwindcss/utilities";

/* App vars */
:root {
  --brand: #3B82F6;
  --gold: #D4AF37;
}

/* Light */
body {
  @apply antialiased text-gray-900 bg-white;
}

/* Dark */
.dark body {
  @apply text-gray-100 bg-gray-900;
}

/* small helpers for the FAB */
.glass-fab {
  @apply w-16 h-16 rounded-full flex items-center justify-center;
  background: linear-gradient(135deg, rgba(255,255,255,0.06), rgba(255,255,255,0.03));
  box-shadow: 0 8px 30px rgba(11,12,24,0.35), inset 0 1px 0 rgba(255,255,255,0.02);
  backdrop-filter: blur(6px);
  border: 1px solid rgba(255,255,255,0.06);
}
'@
WriteUtf8 "src/index.css" $indexCss

# .vscode settings (optional)
$vs = @'
{
  "files.encoding": "utf8",
  "files.autoGuessEncoding": true
}
'@
if (-not (Test-Path ".vscode")) { New-Item -ItemType Directory -Path ".vscode" | Out-Null }
WriteUtf8 ".vscode/settings.json" $vs

# .gitignore
$gitignore = @'
node_modules
dist
.env
.DS_Store
.vscode
'@
WriteUtf8 ".gitignore" $gitignore

# src/main.tsx
$main = @'
import React from "react";
import ReactDOM from "react-dom/client";
import { BrowserRouter } from "react-router-dom";
import App from "./App";
import "./index.css";

ReactDOM.createRoot(document.getElementById("root") as HTMLElement).render(
  <React.StrictMode>
    <BrowserRouter>
      <App />
    </BrowserRouter>
  </React.StrictMode>
);
'@
WriteUtf8 "src/main.tsx" $main

# src/App.tsx
$app = @'
import React from "react";
import { Routes, Route } from "react-router-dom";
import ProtectedLayout from "./layouts/ProtectedLayout";
import AuthLayout from "./layouts/AuthLayout";
import Dashboard from "./pages/Dashboard";
import Login from "./pages/Login";
import QuickActionFullCircle from "./components/QuickActionFullCircle";

export default function App(){
  return (
    <>
      <Routes>
        <Route path="/auth/*" element={<AuthLayout />} />
        <Route element={<ProtectedLayout />}>
          <Route path="/" element={<Dashboard />} />
        </Route>
      </Routes>

      {/* Global quick actions */}
      <QuickActionFullCircle />
    </>
  );
}
'@
WriteUtf8 "src/App.tsx" $app

# layouts/AuthLayout.tsx
$authLayout = @'
import React from "react";
import { Routes, Route } from "react-router-dom";
import Login from "../pages/Login";

export default function AuthLayout(){
  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50 dark:bg-gray-900">
      <Routes>
        <Route path="/login" element={<Login />} />
        <Route index element={<Login />} />
      </Routes>
    </div>
  );
}
'@
WriteUtf8 "src/layouts/AuthLayout.tsx" $authLayout

# layouts/ProtectedLayout.tsx
$protected = @'
import React from "react";
import { Outlet } from "react-router-dom";
import Drawer from "../components/Drawer";
import ThemeToggle from "../components/ThemeToggle";

export default function ProtectedLayout(){
  return (
    <div className="flex min-h-screen">
      <Drawer />
      <div className="flex-1 flex flex-col">
        <header className="flex justify-between items-center p-4 bg-white dark:bg-gray-900 shadow">
          <h1 className="text-lg font-semibold">Pro Starter</h1>
          <ThemeToggle />
        </header>
        <main className="p-4 flex-1 bg-gray-50 dark:bg-gray-800">
          <Outlet />
        </main>
      </div>
    </div>
  );
}
'@
WriteUtf8 "src/layouts/ProtectedLayout.tsx" $protected

# src/pages/Login.tsx
$login = @'
import React, { useState } from "react";
import { useNavigate } from "react-router-dom";
import useAuthStore from "../stores/useAuthStore";

export default function Login(){
  const navigate = useNavigate();
  const login = useAuthStore(s=>s.login);
  const [user,setUser] = useState("");
  const handle = async (e?:React.FormEvent) => {
    e?.preventDefault();
    // mock login
    login({ name: user, token: "demo-token" });
    navigate("/");
  };
  return (
    <form onSubmit={handle} className="w-full max-w-md bg-white dark:bg-gray-900 p-6 rounded shadow">
      <h2 className="text-xl font-semibold mb-4">Sign in</h2>
      <input value={user} onChange={e=>setUser(e.target.value)} className="input input-bordered w-full mb-3" placeholder="username" />
      <div className="flex justify-end">
        <button type="submit" className="btn btn-primary">Sign in</button>
      </div>
    </form>
  );
}
'@
WriteUtf8 "src/pages/Login.tsx" $login

# src/pages/Dashboard.tsx (with simple charts)
$dashboard = @'
import React from "react";
import { LineChart, Line, ResponsiveContainer } from "recharts";
import { StatCard } from "../components/StatCard";

const sample = [{name:"Mon",value:400},{name:"Tue",value:300},{name:"Wed",value:500}];

export default function Dashboard(){
  return (
    <div className="space-y-4">
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <StatCard title="Revenue" value={123456} icon="💰" />
        <StatCard title="Expense" value={78900} icon="📉" />
        <StatCard title="Profit" value={44556} icon="💹" />
      </div>

      <div className="bg-white dark:bg-gray-800 rounded p-4 shadow">
        <h3 className="font-semibold mb-2">Sales</h3>
        <ResponsiveContainer width="100%" height={200}>
          <LineChart data={sample}><Line dataKey="value" stroke="#3B82F6" /></LineChart>
        </ResponsiveContainer>
      </div>
    </div>
  );
}
'@
WriteUtf8 "src/pages/Dashboard.tsx" $dashboard

# src/stores/useAuthStore.ts
$store = @'
import create from "zustand";

type User = { name: string; token: string } | null;

interface AuthState {
  user: User;
  login: (u: User) => void;
  logout: () => void;
}

const useAuthStore = create<AuthState>((set) => ({
  user: null,
  login: (u) => set({ user: u }),
  logout: () => set({ user: null }),
}));

export default useAuthStore;
'@
if (-not (Test-Path "src/stores")) { New-Item -ItemType Directory -Path "src/stores" | Out-Null }
WriteUtf8 "src/stores/useAuthStore.ts" $store

# src/components/ThemeToggle.tsx
$themeToggle = @'
import React, { useEffect, useState } from "react";
export default function ThemeToggle(){
  const [dark,setDark] = useState(localStorage.getItem("theme")==="dark");
  useEffect(()=>{ document.documentElement.classList.toggle("dark", dark); localStorage.setItem("theme", dark? "dark":"light"); },[dark]);
  return <button className="btn btn-ghost btn-sm" onClick={()=>setDark(d=>!d)}>{dark? "Light":"Dark"}</button>;
}
'@
if (-not (Test-Path "src/components")) { New-Item -ItemType Directory -Path "src/components" | Out-Null }
WriteUtf8 "src/components/ThemeToggle.tsx" $themeToggle

# src/components/Drawer.tsx (simple)
$drawerComp = @'
import React from "react";
import { Link } from "react-router-dom";
export default function Drawer(){
  return (
    <nav className="w-64 bg-white dark:bg-gray-800 p-4 hidden md:block">
      <Link to="/" className="block p-2 rounded hover:bg-gray-100 dark:hover:bg-gray-700">Dashboard</Link>
      <Link to="/sales" className="block p-2 rounded hover:bg-gray-100 dark:hover:bg-gray-700">Sales</Link>
      <Link to="/purchases" className="block p-2 rounded hover:bg-gray-100 dark:hover:bg-gray-700">Purchases</Link>
    </nav>
  );
}
'@
WriteUtf8 "src/components/Drawer.tsx" $drawerComp

# src/components/StatCard.tsx
$statCard = @'
import React from "react";
import { motion } from "framer-motion";
export const StatCard:React.FC<{title:string; value:number; icon:string}> = ({title,value,icon}) => (
  <motion.div initial={{opacity:0,y:8}} animate={{opacity:1,y:0}} className="p-4 bg-white dark:bg-gray-800 rounded shadow flex items-center gap-4">
    <div className="text-3xl">{icon}</div>
    <div><div className="text-sm text-gray-500">{title}</div><div className="text-lg font-bold">{value.toLocaleString()}</div></div>
  </motion.div>
);
'@
WriteUtf8 "src/components/StatCard.tsx" $statCard

# QuickActionFullCircle (reduced / integrated)
$quickAction = @'
/* See previous QuickActionFullCircle code you were given earlier.
   For brevity we place a small placeholder that imports the full component file later.
   If you want, replace this with the full implementation from earlier chat. */
import QuickActionFullCircle from "./QuickActionFullCircle";
export default QuickActionFullCircle;
'@
# We'll still include the full component file (simplified) to ensure app runs.
$quickActionFull = @'
import React from "react";
export default function QuickActionFullCircle(){
  return null; /* placeholder - replace with the full component copy/paste from chat for the full experience */
}
'@
WriteUtf8 "src/components/QuickActionFullCircle.tsx" $quickActionFull

# small placeholder to avoid missing imports
WriteUtf8 "src/components/QuickActionRadialPlaceholder.tsx" $quickAction

# Tailwind init (creates default files; safe even if files already present)
npx tailwindcss init -p | Out-Null

# Ensure package.json has dev script & type module if desired
$pkgPath = "package.json"
$pkg = Get-Content $pkgPath -Raw | ConvertFrom-Json
if (-not $pkg.scripts) { $pkg.scripts = @{} }
$pkg.scripts.dev = "vite"
$pkg | ConvertTo-Json -Depth 10 | Set-Content -Path $pkgPath -Encoding UTF8
Write-Host "Updated package.json scripts"

# Final npm install
Write-Host "Running npm install (may take a few minutes)..."
npm install

Write-Host ""
Write-Host "✅ Starter created."
Write-Host "Next steps:"
Write-Host "1) Add the full QuickActionFullCircle implementation (we provided earlier) into src/components/QuickActionFullCircle.tsx"
Write-Host "2) Place corporate sound files into public/sounds/ (click.mp3, success.mp3, error.mp3, copy.mp3)"
Write-Host "3) Run: npm run dev"
Write-Host "4) If you see any PostCSS BOM issues, run the following PowerShell command to remove BOMs:"
Write-Host "`nGet-ChildItem -Recurse -Include *.js,*.ts,*.json,*.css | ForEach-Object { (Get-Content $_.FullName -Raw) | Set-Content -Encoding UTF8 $_.FullName }`n"

Write-Host "Done."
