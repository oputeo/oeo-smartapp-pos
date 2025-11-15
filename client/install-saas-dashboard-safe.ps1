# install-saas-dashboard-full.ps1
# Full SaaS Dashboard Installer with Tailwind, DaisyUI, Recharts, Framer Motion, ThemeToggle, Drawer, Reports, Action buttons

$projectRoot = Get-Location
Write-Host "Working directory: $projectRoot"

function Abort($msg) { Write-Host "ERROR: $msg" -ForegroundColor Red; exit 1 }
if (-not (Test-Path (Join-Path $projectRoot "package.json"))) { Abort "package.json not found. Run the script from your project root." }

# 1) Clean old Tailwind/PostCSS configs
$toRemove = @("tailwind.config.js","tailwind.config.cjs","tailwind.config.mjs","postcss.config.js","postcss.config.cjs","postcss.config.mjs")
foreach ($f in $toRemove) { if (Test-Path $f) { Remove-Item $f -Force -ErrorAction SilentlyContinue } }

# 2) Install dependencies
$devDeps = @("tailwindcss","@tailwindcss/postcss","postcss","autoprefixer","daisyui")
$deps = @("react","react-dom","react-router-dom","framer-motion","recharts","react-hot-toast","react-icons","xlsx")
npm install -D $devDeps
npm install $deps

# 3) PostCSS config
$postcssPath = Join-Path $projectRoot "postcss.config.cjs"
@'
module.exports = {
  plugins: {
    "@tailwindcss/postcss": {},
    autoprefixer: {},
  },
};
'@ | Set-Content -Path $postcssPath -Encoding UTF8

# 4) Tailwind config
$tailwindPath = Join-Path $projectRoot "tailwind.config.cjs"
@'
module.exports = {
  darkMode: "class",
  content: ["./index.html","./src/**/*.{js,ts,jsx,tsx}"],
  theme: { extend: { colors: { brand:{ DEFAULT:"#3B82F6",light:"#60A5FA",dark:"#1E40AF",gold:"#D4AF37" } } } },
  plugins:[require("daisyui")],
  daisyui:{ themes:[{light:{primary:"#3B82F6",secondary:"#60A5FA",accent:"#ffd166",neutral:"#111827","base-100":"#ffffff",info:"#3abff8",success:"#36d399",warning:"#fbbd23",error:"#ef4444"}},"dark"], darkTheme:"dark", base:true }
};
'@ | Set-Content -Path $tailwindPath -Encoding UTF8

# 5) index.css UTF-8 no BOM
$srcPath = Join-Path $projectRoot "src"; if (-not (Test-Path $srcPath)) { New-Item -ItemType Directory -Path $srcPath | Out-Null }
$indexCssPath = Join-Path $srcPath "index.css"
@'
@tailwind base;
@tailwind components;
@tailwind utilities;

:root { --brand:#3B82F6; --gold:#D4AF37; }

body { @apply antialiased font-sans bg-white text-gray-900; }
.dark body { @apply bg-gray-900 text-gray-100; }

'@ | Set-Content -Path $indexCssPath -Encoding UTF8

# 6) ThemeToggle.tsx
$themeTogglePath = Join-Path $srcPath "ThemeToggle.tsx"
@'
import { useEffect, useState } from "react";

export default function ThemeToggle() {
  const [dark, setDark] = useState(false);
  useEffect(() => { if(dark) document.documentElement.classList.add("dark"); else document.documentElement.classList.remove("dark"); },[dark]);
  return <button className="btn btn-sm btn-primary" onClick={()=>setDark(!dark)}>{dark?"Light":"Dark"} Mode</button>;
}
'@ | Set-Content -Path $themeTogglePath -Encoding UTF8

# 7) Navigation Drawer
$drawerPath = Join-Path $srcPath "Drawer.tsx"
@'
import { Link } from "react-router-dom";
export default function Drawer() {
  return (
    <div className="w-64 bg-gray-100 dark:bg-gray-800 h-screen p-4 space-y-4">
      <Link className="block p-2 rounded hover:bg-gray-200 dark:hover:bg-gray-700" to="/">Home</Link>
      <Link className="block p-2 rounded hover:bg-gray-200 dark:hover:bg-gray-700" to="/sales">Sales</Link>
      <Link className="block p-2 rounded hover:bg-gray-200 dark:hover:bg-gray-700" to="/purchases">Purchases</Link>
      <Link className="block p-2 rounded hover:bg-gray-200 dark:hover:bg-gray-700" to="/reports">Reports</Link>
    </div>
  );
}
'@ | Set-Content -Path $drawerPath -Encoding UTF8

# 8) Dashboard.tsx with Recharts + Framer Motion + Action Buttons + Report dropdown
$dashboardPath = Join-Path $srcPath "Dashboard.tsx"
@'
import { LineChart, Line, PieChart, Pie, Cell, Tooltip, Legend, ResponsiveContainer } from "recharts";
import { motion } from "framer-motion";
import { toast, Toaster } from "react-hot-toast";
import { useState } from "react";

const lineData=[{name:"Mon",Sales:400},{name:"Tue",Sales:300},{name:"Wed",Sales:500}];
const pieData=[{name:"Revenue",value:500},{name:"Expense",value:200}];
const COLORS=["#0088FE","#00C49F"];

export default function Dashboard(){
  const [period,setPeriod]=useState("Today");
  const handleAction=(msg:string)=>toast.success(msg);
  return (
    <div className="p-4 flex-1 space-y-4">
      <Toaster />
      <motion.div initial={{opacity:0}} animate={{opacity:1}} transition={{duration:0.8}} className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div className="card p-4 shadow cursor-pointer" onClick={()=>handleAction("Revenue clicked")}>Revenue: $500</div>
        <div className="card p-4 shadow cursor-pointer" onClick={()=>handleAction("Expense clicked")}>Expense: $200</div>
        <div className="card p-4 shadow cursor-pointer" onClick={()=>handleAction("Profit clicked")}>Profit: $300</div>
      </motion.div>

      <div className="flex items-center space-x-4">
        <select className="select select-bordered" value={period} onChange={e=>setPeriod(e.target.value)}>
          <option>Today</option>
          <option>Yesterday</option>
          <option>This Week</option>
          <option>Last Week</option>
        </select>
        <button className="btn btn-primary" onClick={()=>handleAction("Excel exported")}>Export Excel</button>
      </div>

      <motion.div initial={{y:50,opacity:0}} animate={{y:0,opacity:1}} transition={{duration:1}}>
        <h2 className="text-lg font-semibold">Sales Chart</h2>
        <ResponsiveContainer width="100%" height={200}><LineChart data={lineData}><Line type="monotone" dataKey="Sales" stroke="#8884d8" /></LineChart></ResponsiveContainer>
      </motion.div>

      <motion.div initial={{y:50,opacity:0}} animate={{y:0,opacity:1}} transition={{duration:1.2}}>
        <h2 className="text-lg font-semibold">Revenue vs Expense</h2>
        <ResponsiveContainer width="100%" height={200}><PieChart><Pie data={pieData} dataKey="value" nameKey="name" cx="50%" cy="50%" outerRadius={60}>
          {pieData.map((entry,index)=><Cell key={index} fill={COLORS[index%COLORS.length]} />)}
          </Pie><Tooltip /><Legend /></PieChart></ResponsiveContainer>
      </motion.div>

      {/* Floating action buttons */}
      <div className="fixed bottom-4 right-4 flex flex-col space-y-2">
        <button className="btn btn-primary" onClick={()=>handleAction("New Customer")}>New Customer</button>
        <button className="btn btn-secondary" onClick={()=>handleAction("New Invoice")}>New Invoice</button>
        <button className="btn btn-accent" onClick={()=>handleAction("New Purchase")}>New Purchase</button>
        <button className="btn btn-info" onClick={()=>handleAction("New Expense")}>New Expense</button>
      </div>
    </div>
  );
}
'@ | Set-Content -Path $dashboardPath -Encoding UTF8

# 9) Main.tsx with Drawer + ThemeToggle + Routes
$mainPath = Join-Path $srcPath "main.tsx"
@'
import React from "react";
import ReactDOM from "react-dom/client";
import { BrowserRouter, Routes, Route } from "react-router-dom";
import Dashboard from "./Dashboard";
import Drawer from "./Drawer";
import ThemeToggle from "./ThemeToggle";
import "./index.css";

ReactDOM.createRoot(document.getElementById("root")!).render(
  <React.StrictMode>
    <div className="flex">
      <Drawer />
      <div className="flex-1">
        <div className="flex justify-between p-4 items-center"><h1 className="text-xl font-bold">My SaaS Dashboard</h1><ThemeToggle /></div>
        <Routes>
          <Route path="/" element={<Dashboard />} />
        </Routes>
      </div>
    </div>
  </React.StrictMode>
);
'@ | Set-Content -Path $mainPath -Encoding UTF8

# 10) Ensure dev script
$pkgPath = Join-Path $projectRoot "package.json"
$pkg = Get-Content -Path $pkgPath -Raw | ConvertFrom-Json
if (-not $pkg.scripts) { $pkg.scripts=@{} }
if (-not $pkg.scripts.dev) { $pkg.scripts.dev="vite" }
$pkg | ConvertTo-Json -Depth 10 | Set-Content -Path $pkgPath -Encoding UTF8

# 11) Install & finish
npm install
Write-Host "`n✅ Full SaaS dashboard setup complete! Run: npm run dev"
