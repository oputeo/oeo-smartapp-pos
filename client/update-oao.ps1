# =============================================
# OEO SMARTAPP v8 — AUTOMATED UPDATE SCRIPT
# Updates: Calculator + Workflow + Imports
# =============================================

$AppPath = "src\App.tsx"
$WorkflowPath = "src\components\WorkflowModal.tsx"
$DBPath = "src\db\indexeddb.ts"

Write-Host "OEO SMARTAPP v8 — AUTOMATED UPDATE STARTED..." -ForegroundColor Green

# === 1. CREATE WorkflowModal.tsx ===
@'
import React from 'react'
import { X, FileText, Users, DollarSign, Package, Truck } from 'lucide-react'

interface WorkflowModalProps {
  isOpen: boolean
  onClose: () => void
}

export default function WorkflowModal({ isOpen, onClose }: WorkflowModalProps) {
  if (!isOpen) return null

  const workflows = [
    { icon: FileText, label: 'Material Request', color: 'text-blue-600' },
    { icon: DollarSign, label: 'Cash Advance', color: 'text-green-600' },
    { icon: Users, label: 'Salary Advance', color: 'text-purple-600' },
    { icon: Package, label: 'Stock Transfer', color: 'text-orange-600' },
    { icon: Truck, label: 'Delivery Note', color: 'text-indigo-600' },
  ]

  return (
    <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50" onClick={onClose}>
      <div 
        className="bg-white dark:bg-gray-800 rounded-3xl p-8 max-w-md w-full mx-4 shadow-2xl"
        onClick={e => e.stopPropagation()}
      >
        <div className="flex justify-between items-center mb-6">
          <h2 className="text-2xl font-bold text-primary">Start Workflow</h2>
          <button onClick={onClose} className="text-gray-400 hover:text-red-500">
            <X size={24} />
          </button>
        </div>
        <div className="space-y-3">
          {workflows.map((wf, i) => (
            <button
              key={i}
              className="w-full p-4 bg-gray-50 dark:bg-gray-700 rounded-xl hover:bg-gray-100 dark:hover:bg-gray-600 transition flex items-center gap-3"
            >
              <div className={`p-2 rounded-lg bg-gradient-to-br from-gray-100 to-gray-200 dark:from-gray-600 dark:to-gray-700`}>
                <wf.icon size={20} className={wf.color} />
              </div>
              <span className="font-semibold">{wf.label}</span>
            </button>
          ))}
        </div>
      </div>
    </div>
  )
}
'@ | Out-File -FilePath $WorkflowPath -Encoding UTF8 -Force
Write-Host "WorkflowModal.tsx CREATED" -ForegroundColor Cyan

# === 2. UPDATE App.tsx — ADD STATE + IMPORT + LAUNCHER ===
$AppContent = Get-Content $AppPath -Raw

# Add import
if ($AppContent -notmatch "import WorkflowModal") {
  $AppContent = $AppContent -replace 
    '(import \{ PDFDocument[^}]*\} from .pdf-lib.)', 
    "`$1`n`nimport WorkflowModal from './components/WorkflowModal'"
}

# Add state
if ($AppContent -notmatch 'showWorkflow') {
  $AppContent = $AppContent -replace 
    '(const \[showCalc,[^]]*\] = useState\(false\))', 
    "`$1`n  const [showWorkflow, setShowWorkflow] = useState(false)"
}

# Replace launcher
$AppContent = $AppContent -replace 
  '(?s)<!-- QUICK TRANSACTION LAUNCHER -->.*?<!-- END LAUNCHER -->', 
  @'
      <!-- MULTI-WORKFLOW LAUNCHER -->
      <button
        onClick={() => {
          setShowWorkflow(true)
          playSound()
        }}
        className="fixed bottom-8 right-8 w-16 h-16 bg-gradient-to-br from-indigo-500 to-purple-600 text-white rounded-full shadow-2xl flex items-center justify-center hover:scale-110 transition-all z-50 border-4 border-white dark:border-gray-800"
      >
        <FileText size={28} strokeWidth={3} />
      </button>

      <WorkflowModal isOpen={showWorkflow} onClose={() => setShowWorkflow(false)} />
'@

$AppContent | Out-File -FilePath $AppPath -Encoding UTF8 -Force
Write-Host "App.tsx UPDATED: Workflow + Import + Launcher" -ForegroundColor Cyan

# === 3. UPDATE CALCULATOR POSITION & SIZE ===
$AppContent = Get-Content $AppPath -Raw

$AppContent = $AppContent -replace 
  '(id="money-calc"[^>]*className="fixed bottom-40)', 
  'id="money-calc" className="fixed bottom-44'

$AppContent = $AppContent -replace 
  '(input input-bordered input-sm)', 
  'input input-bordered input-lg'

$AppContent = $AppContent -replace 
  '(text-2xl font-bold text-primary)', 
  'text-3xl font-black bg-gradient-to-r from-green-600 to-emerald-600 bg-clip-text text-transparent'

$AppContent | Out-File -FilePath $AppPath -Encoding UTF8 -Force
Write-Host "Calculator FIXED: Position + Bigger Numbers" -ForegroundColor Cyan

# === 4. CREATE indexeddb.ts (if missing) ===
if (-not (Test-Path $DBPath)) {
@'
const DB_NAME = 'OEO_DB'
const DB_VERSION = 1
const STORES = ['transactions', 'customers', 'inventory']

export const initDB = (): Promise<IDBDatabase> => {
  return new Promise((resolve, reject) => {
    const request = indexedDB.open(DB_NAME, DB_VERSION)

    request.onupgradeneeded = (e: any) => {
      const db = e.target.result
      STORES.forEach(store => {
        if (!db.objectStoreNames.contains(store)) {
          db.createObjectStore(store, { keyPath: 'id', autoIncrement: true })
        }
      })
    }

    request.onsuccess = () => resolve(request.result)
    request.onerror = () => reject(request.error)
  })
}

export const saveData = async (store: string, data: any) => {
  const db = await initDB()
  return new Promise((resolve, reject) => {
    const tx = db.transaction(store, 'readwrite')
    const request = tx.objectStore(store).add(data)
    request.onsuccess = () => resolve(request.result)
    request.onerror = () => reject(request.error)
  })
}
'@ | Out-File -FilePath $DBPath -Encoding UTF8 -Force
Write-Host "indexeddb.ts CREATED" -ForegroundColor Cyan
}

Write-Host "`nOEO SMARTAPP v8 — UPDATE COMPLETE!" -ForegroundColor Green
Write-Host "RUN: npm run dev -- --force" -ForegroundColor Yellow
