# install-saas-dashboard.ps1
# PowerShell installer for DaisyUI SaaS Dashboard (Option A)
# Run from project root (where package.json lives)

$ErrorActionPreference = "Stop"

function Abort($msg) {
    Write-Host "ERROR: $msg" -ForegroundColor Red
    exit 1
}

# Ensure package.json exists
if (-not (Test-Path "package.json")) { Abort "package.json not found in this folder." }

# 1) Install dependencies
Write-Host "`nInstalling dependencies..."
npm install -D tailwindcss @tailwindcss/postcss postcss autoprefixer daisyui
npm install react-router-dom recharts framer-motion react-hot-toast xlsx react-icons
Write-Host "Dependencies installed."

# 2) Create PostCSS config
$postcss = @'
module.exports = {
  plugins: {
    "@tailwindcss/postcss": {},
    autoprefixer: {},
  },
};
'@
Set-Content -Path "postcss.config.cjs" -Value $postcss -Encoding UTF8
Write-Host "Created postcss.config.cjs"

# 3) Create Tailwind config
$tailwind = @'
/** @type {import("tailwindcss").Config} */
module.exports = {
  darkMode: "class",
  content: ["./index.html","./src/**/*.{js,ts,jsx,tsx}"],
  theme: { extend: { colors: { brand: { DEFAULT:"#3B82F6", light:"#60A5FA", dark:"#1E40AF", gold:"#D4AF37" } } } },
  plugins: [require("daisyui")],
  daisyui: {
    themes: [
      { light: { "primary":"#3B82F6","secondary":"#60A5FA","accent":"#ffd166","neutral":"#111827","base-100":"#ffffff","info":"#3abff8","success":"#36d399","warning":"#fbbd23","error":"#ef4444" } },
      "dark"
    ],
    darkTheme:"dark",
    base:true
  }
};
'@
Set-Content -Path "tailwind.config.cjs" -Value $tailwind -Encoding UTF8
Write-Host "Created tailwind.config.cjs"

# 4) Ensure src/index.css exists
if (-not (Test-Path "src")) { New-Item -ItemType Directory -Path "src" | Out-Null }
$indexCss = @'
@tailwind base;
@tailwind components;
@tailwind utilities;

body { @apply antialiased font-sans bg-white dark:bg-gray-900 text-gray-900 dark:text-gray-100 }
'@
Set-Content -Path "src/index.css" -Value $indexCss -Encoding UTF8
Write-Host "Created src/index.css"

# 5) Create components folder
$components = "src/components"
$widgets = "src/widgets"
$pages = "src/pages"
@($components,$widgets,$pages) | ForEach-Object { if (-not (Test-Path $_)) { New-Item -ItemType Directory -Path $_ | Out-Null } }

# 6) Create ThemeToggle.tsx
$themeToggle = @'
import { useState, useEffect } from "react";

export const ThemeToggle = () => {
  const [dark, setDark] = useState(localStorage.getItem("theme") === "dark");
  useEffect(() => {
    document.documentElement.classList.toggle("dark", dark);
    localStorage.setItem("theme", dark ? "dark" : "light");
  }, [dark]);
  return <button className="btn btn-sm btn-outline" onClick={()=>setDark(!dark)}>{dark ? "🌙 Dark" : "☀️ Light"}</button>;
};
'@
Set-Content -Path "$components/ThemeToggle.tsx" -Value $themeToggle -Encoding UTF8

# 7) Create NavigationDrawer.tsx
$drawer = @'
import { useState } from "react";
import { motion } from "framer-motion";

export const NavigationDrawer = () => {
  const [open, setOpen] = useState(true);
  const items = ["Home","Sales","Purchases","Inventory","Reports"];
  return (
    <motion.div initial={{x:-300}} animate={{x:open?0:-300}} className="fixed top-0 left-0 h-full w-64 bg-white dark:bg-gray-800 shadow-lg p-4 z-50">
      <button className="btn btn-sm mb-4" onClick={()=>setOpen(!open)}>{open ? "Close" : "Open"}</button>
      <ul>{items.map(i=><li key={i} className="my-2 hover:text-blue-500">{i}</li>)}</ul>
    </motion.div>
  );
};
'@
Set-Content -Path "$components/NavigationDrawer.tsx" -Value $drawer -Encoding UTF8

# 8) Create QuickReport.tsx
$quickReport = @'
import { useState } from "react";
import { LineChartWidget } from "../widgets/LineChartWidget";
import { PieChartWidget } from "../widgets/PieChartWidget";
import * as XLSX from "xlsx";

export const QuickReport = () => {
  const [reportType,setReportType]=useState("Sales");
  const [period,setPeriod]=useState("Previous Day");
  const exportExcel=()=>{const ws=XLSX.utils.json_to_sheet([{Example:"Data"}]);const wb=XLSX.utils.book_new();XLSX.utils.book_append_sheet(wb,ws,"Report");XLSX.writeFile(wb,`${reportType}-${period}.xlsx`);};
  return (
    <div className="p-4 bg-gray-100 dark:bg-gray-900 rounded-lg shadow mb-4">
      <div className="flex gap-4 items-center mb-4">
        <select value={reportType} onChange={e=>setReportType(e.target.value)} className="select select-bordered">{["Sales","Cash Sales","Production","Receivable","Payable","Inventory"].map(r=><option key={r}>{r}</option>)}</select>
        <select value={period} onChange={e=>setPeriod(e.target.value)} className="select select-bordered">{["Previous Day","Previous Week","Month","Last Quarter"].map(p=><option key={p}>{p}</option>)}</select>
        <button className="btn btn-primary" onClick={exportExcel}>Export Excel</button>
      </div>
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <LineChartWidget reportType={reportType} period={period}/>
        <PieChartWidget reportType={reportType} period={period}/>
      </div>
    </div>
  );
};
'@
Set-Content -Path "$components/QuickReport.tsx" -Value $quickReport -Encoding UTF8

# 9) Create FloatingActions.tsx
$floating = @'
import { motion } from "framer-motion";

export const FloatingActions = () => (
  <motion.div initial={{opacity:0,y:50}} animate={{opacity:1,y:0}} className="fixed bottom-8 right-8 flex flex-col gap-2">
    {["New Customer","New Invoice","New Purchase","New Expense"].map(a=><button key={a} className="btn btn-primary btn-sm">{a}</button>)}
  </motion.div>
);
'@
Set-Content -Path "$components/FloatingActions.tsx" -Value $floating -Encoding UTF8

# 10) Create FinanceCalculator.tsx
$calculator = @'
import { useState } from "react";
const currencies={NGN:[1000,500,200,100,50,20,10,5],USD:[100,50,20,10,5,1],EUR:[500,200,100,50,20,10,5]};

export const MoneyCalculator=()=>{
  const [currency,setCurrency]=useState("NGN"); const [amount,setAmount]=useState(0);
  const breakdown=()=>{let rem=amount; return currencies[currency].map(b=>{const c=Math.floor(rem/b); rem-=c*b; return {bill:b,count:c}});}
  return (
    <div className="p-4 bg-gray-100 dark:bg-gray-900 rounded-lg shadow">
      <div className="flex gap-2 mb-2">
        <select value={currency} onChange={e=>setCurrency(e.target.value)} className="select select-bordered">{Object.keys(currencies).map(c=><option key={c}>{c}</option>)}</select>
        <input type="number" value={amount} onChange={e=>setAmount(+e.target.value)} className="input input-bordered" placeholder="Amount"/>
      </div>
      <ul>{breakdown().map(b=><li key={b.bill}>{b.count} x {b.bill} {currency}</li>)}</ul>
    </div>
  );
};
'@
Set-Content -Path "$components/FinanceCalculator.tsx" -Value $calculator -Encoding UTF8

# 11) Create StatCard.tsx
$statCard = @'
export const StatCard=({title,value,icon}:{title:string,value:number,icon:string})=>(
  <div className="p-4 bg-white dark:bg-gray-800 rounded-lg shadow flex items-center gap-4">
    <div className="text-3xl">{icon}</div>
    <div>
      <div className="text-gray-500 dark:text-gray-400">{title}</div>
      <div className="text-xl font-bold">{value.toLocaleString()}</div>
    </div>
  </div>
);
'@
Set-Content -Path "$widgets/StatCard.tsx" -Value $statCard -Encoding UTF8

# 12) Create placeholder chart widgets
$lineChart = @'
export const LineChartWidget=({reportType,period}:{reportType:string,period:string})=><div className="h-64 bg-gray-200 dark:bg-gray-700 rounded-lg flex items-center justify-center">Line Chart: {reportType} - {period}</div>;
'@
Set-Content -Path "$widgets/LineChartWidget.tsx" -Value $lineChart -Encoding UTF8

$pieChart = @'
export const PieChartWidget=({reportType,period}:{reportType:string,period:string})=><div className="h-64 bg-gray-300 dark:bg-gray-600 rounded-lg flex items-center justify-center">Pie Chart: {reportType} - {period}</div>;
'@
Set-Content -Path "$widgets/PieChartWidget.tsx" -Value $pieChart -Encoding UTF8

# 13) Create Dashboard.tsx
$dashboard = @'
import { NavigationDrawer } from "../components/NavigationDrawer";
import { ThemeToggle } from "../components/ThemeToggle";
import { QuickReport } from "../components/QuickReport";
import { StatCard } from "../widgets/StatCard";
import { FloatingActions } from "../components/FloatingActions";
import { MoneyCalculator } from "../components/FinanceCalculator";

export const Dashboard = () => (
  <div className="flex">
    <NavigationDrawer />
    <div className="flex-1 p-6 ml-64">
      <div className="flex justify-between items-center mb-4">
        <h1 className="text-2xl font-bold">Dashboard</h1>
        <ThemeToggle />
      </div>
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-4">
        <StatCard title="Revenue" value={123456} icon="💰"/>
        <StatCard title="Expense" value={78900} icon="📉"/>
        <StatCard title="Profit" value={44556} icon="💹"/>
      </div>
      <QuickReport />
      <MoneyCalculator />
      <FloatingActions />
    </div>
  </div>
);
'@
Set-Content -Path "$pages/Dashboard.tsx" -Value $dashboard -Encoding UTF8

# 14) Update src/main.tsx
$mainTsx = @'
import React from "react";
import ReactDOM from "react-dom/client";
import "./index.css";
import { BrowserRouter, Routes, Route } from "react-router-dom";
import { Dashboard } from "./pages/Dashboard";

ReactDOM.createRoot(document.getElementById("root")!).render(
  <React.StrictMode>
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Dashboard />} />
      </Routes>
    </BrowserRouter>
  </React.StrictMode>
);
'@
Set-Content -Path "src/main.tsx" -Value $mainTsx -Encoding UTF8

# 15) Add dev script to package.json
$pkgRaw = Get-Content "package.json" -Raw
$pkg = $pkgRaw | ConvertFrom-Json
if (-not $pkg.scripts) { $pkg.scripts = @{} }
if (-not $pkg.scripts.dev) { $pkg.scripts.dev = "vite"; $pkg | ConvertTo-Json -Depth 10 | Set-Content "package.json" -Encoding UTF8; Write-Host "Added 'dev' script to package.json" }

# 16) Initialize Tailwind (safeguard)
npx tailwindcss init -p | Out-Null

# 17) Start dev server
Write-Host "`nStarting dev server... Ctrl+C to stop"
Start-Process -FilePath "npm" -ArgumentList "run","dev" -NoNewWindow
