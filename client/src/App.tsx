// src/App.tsx
import { useState, useEffect, useRef, useMemo } from 'react'
import {
  Menu, X, Home, ShoppingCart, Package, Download, QrCode, Printer,
  Sun, Moon, LogOut, Settings, Bell, DollarSign, Copy, RotateCcw,
  TrendingUp, FileText
} from 'lucide-react'
import { saveAs } from 'file-saver'
import jsQR from 'jsqr'
import useAuthStore from './stores/useAuthStore'
import { Camera, CameraResultType } from '@capacitor/camera'
import { LineChart, Line, PieChart, Pie, Cell, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts'
import { PDFDocument, StandardFonts, rgb } from 'pdf-lib'
import WorkflowModal from './components/WorkflowModal'
import { saveData } from './db/indexeddb'

const COLORS = ['#3b82f6', '#10b981', '#f59e0b', '#ef4444']

const CURRENCIES = {
  NGN: { symbol: '₦', rates: [1000, 500, 200, 100, 50, 20, 10, 5] },
  USD: { symbol: '$', rates: [100, 50, 20, 10, 5, 1] },
  EUR: { symbol: '€', rates: [500, 200, 100, 50, 20, 10, 5] },
}

interface SalesData {
  date: string
  sales: number
  cashSales: number
  production: number
  expense: number
}

const generateSalesData = (days: number): SalesData[] => {
  const data: SalesData[] = []
  for (let i = 0; i < days; i++) {
    const date = new Date()
    date.setDate(date.getDate() - i)
    data.push({
      date: date.toISOString().split('T')[0],
      sales: Math.floor(Math.random() * 5000) + 2000,
      cashSales: Math.floor(Math.random() * 4000) + 1500,
      production: Math.floor(Math.random() * 3000) + 1000,
      expense: Math.floor(Math.random() * 3000) + 1000,
    })
  }
  return data.reverse()
}

const MOCK_DATA = { all: generateSalesData(90) }

export default function App() {
  const [isDrawerOpen, setIsDrawerOpen] = useState(true)
  const [isDark, setIsDark] = useState(false)
  const [showCalc, setShowCalc] = useState(false)
  const [showWorkflow, setShowWorkflow] = useState(false)
  const [currency, setCurrency] = useState<'NGN' | 'USD' | 'EUR'>('NGN')
  const [denomCounts, setDenomCounts] = useState<Record<number, number>>({})
  const [receiptNumber, setReceiptNumber] = useState(1001)
  const [reportType, setReportType] = useState<'sales' | 'cashSales' | 'production'>('sales')
  const [reportPeriod, setReportPeriod] = useState<'yesterday' | 'lastWeek' | 'lastMonth' | 'lastQuarter'>('lastWeek')

  const audioRef = useRef<HTMLAudioElement | null>(null)
  const { user, logout } = useAuthStore()

  useEffect(() => {
    document.body.classList.toggle('dark', isDark)
    audioRef.current = new Audio('data:audio/wav;base64,UklGRnoGAABXQVZFZm10IBAAAAABAAEAQB8AAEAfAAABAAgAZGF0YQoGAACBhYqFbF1fdJivrJBhNjVgodDbq2EcBj+a2/LDciUFLIHO8tiJNwgZ')
  }, [isDark])

  const filteredData = useMemo(() => {
    const data = MOCK_DATA.all
    const now = new Date()
    let filtered: SalesData[] = []

    switch (reportPeriod) {
      case 'yesterday':
        const yesterday = new Date(now)
        yesterday.setDate(yesterday.getDate() - 1)
        filtered = data.filter(d => new Date(d.date).toDateString() === yesterday.toDateString())
        break
      case 'lastWeek':
        const weekAgo = new Date(now)
        weekAgo.setDate(weekAgo.getDate() - 7)
        filtered = data.filter(d => new Date(d.date) >= weekAgo)
        break
      case 'lastMonth':
        const monthAgo = new Date(now)
        monthAgo.setMonth(monthAgo.getMonth() - 1)
        filtered = data.filter(d => new Date(d.date) >= monthAgo)
        break
      case 'lastQuarter':
        const quarterAgo = new Date(now)
        quarterAgo.setMonth(quarterAgo.getMonth() - 3)
        filtered = data.filter(d => new Date(d.date) >= quarterAgo)
        break
    }

    return filtered.map(d => ({
      name: new Date(d.date).toLocaleDateString('en', { weekday: 'short' }),
      value: d[reportType],
    }))
  }, [reportType, reportPeriod])

  const pieData = useMemo(() => {
    return [
      { name: 'Sales', value: 55 },
      { name: 'Cash', value: 25 },
      { name: 'Production', value: 15 },
      { name: 'Profit', value: 5 },
    ]
  }, [filteredData])

  const totalAmount = Object.entries(denomCounts).reduce((sum, [denom, count]) => sum + (Number(denom) * count), 0)

  const playSound = () => {
    if (audioRef.current) {
      audioRef.current.currentTime = 0
      audioRef.current.play().catch(() => {})
    }
    if ('vibrate' in navigator) navigator.vibrate?.([50])
  }

  const copyTotal = () => {
    navigator.clipboard.writeText(totalAmount.toString())
    alert('Copied to clipboard!')
    playSound()
  }

  const resetCalc = () => {
    setDenomCounts({})
    playSound()
  }

  const exportToCSV = () => {
    const csv = `Date,${reportType.charAt(0).toUpperCase() + reportType.slice(1)}\n${filteredData.map(d => `${d.name},${d.value}`).join('\n')}`
    const blob = new Blob([csv], { type: 'text/csv' })
    saveAs(blob, `${reportType}_${reportPeriod}.csv`)
    playSound()
  }

  const printReceipt = async () => {
    const pdfDoc = await PDFDocument.create()
    const page = pdfDoc.addPage([300, 600])
    const font = await pdfDoc.embedFont(StandardFonts.Helvetica)
    const { width, height } = page.getSize()

    page.drawText('OEO SMARTAPP', { x: width / 2 - 60, y: height - 50, size: 16, font, color: rgb(0, 0, 0) })
    page.drawText(`Receipt #${receiptNumber}`, { x: 20, y: height - 80, size: 10, font })
    page.drawText(`Date: ${new Date().toLocaleString()}`, { x: 20, y: height - 100, size: 10, font })
    page.drawText('--------------------------------', { x: 20, y: height - 120, size: 10, font })
    page.drawText(`Total: ${CURRENCIES[currency].symbol}${totalAmount.toLocaleString()}`, { x: 20, y: height - 140, size: 12, font })
    page.drawText('Thank You!', { x: width / 2 - 40, y: 50, size: 12, font })

    const pdfBytes = await pdfDoc.save()
    const blob = new Blob([new Uint8Array(pdfBytes)], { type: 'application/pdf' }) // FINAL & FINAL FIX
    saveAs(blob, `receipt_${receiptNumber}.pdf`)
    setReceiptNumber(prev => prev + 1)

    try {
      await saveData('transactions', {
        type: 'receipt',
        amount: totalAmount,
        currency,
        date: new Date().toISOString(),
        receiptNumber
      })
    } catch (e) {
      console.warn('Offline save failed', e)
    }

    playSound()
  }

  const startQRScanner = async () => {
    try {
      const image = await Camera.getPhoto({
        quality: 90,
        allowEditing: false,
        resultType: CameraResultType.Base64
      })

      const img = new Image()
      img.onload = () => {
        const canvas = document.createElement('canvas')
        canvas.width = img.width
        canvas.height = img.height
        const ctx = canvas.getContext('2d')
        if (ctx && image.base64String) {
          ctx.drawImage(img, 0, 0)
          const imageData = ctx.getImageData(0, 0, canvas.width, canvas.height)
          const code = jsQR(imageData.data, imageData.width, imageData.height)
          if (code) {
            alert(`QR Scanned: ${code.data}`)
            playSound()
          }
        }
      }
      img.src = `data:image/jpeg;base64,${image.base64String}`
    } catch (e) {
      alert('Camera not available in browser.')
    }
  }

  return (
    <div className={`min-h-screen ${isDark ? 'dark bg-gray-900 text-white' : 'bg-gradient-to-br from-blue-50 to-blue-100'} font-sans`}>
      {/* DRAWER */}
      {isDrawerOpen && (
        <div className={`${isDark ? 'bg-gray-800' : 'bg-white'} fixed inset-y-0 left-0 w-64 shadow-2xl z-50 p-6`}>
          <div className="flex justify-between items-center mb-8">
            <h2 className="text-2xl font-bold text-primary">OEO</h2>
            <button onClick={() => setIsDrawerOpen(false)}><X size={24} /></button>
          </div>
          {[
            { icon: Home, label: 'Home' },
            { icon: ShoppingCart, label: 'Sales' },
            { icon: Package, label: 'Purchases' },
            { icon: QrCode, label: 'QR Scan', onClick: startQRScanner },
            { icon: Printer, label: 'Print', onClick: printReceipt },
            { icon: Settings, label: 'Settings' },
          ].map(({ icon: Icon, label, onClick }) => (
            <button
              key={label}
              onClick={onClick}
              className="flex items-center gap-3 p-3 rounded-lg hover:bg-blue-100 dark:hover:bg-gray-700 w-full text-left transition"
            >
              <Icon size={20} />
              <span>{label}</span>
            </button>
          ))}
          <div className="mt-auto pt-8">
            <button onClick={logout} className="flex items-center gap-3 p-3 rounded-lg hover:bg-red-100 dark:hover:bg-red-900 w-full text-left">
              <LogOut size={20} />
              <span>Logout</span>
            </button>
          </div>
        </div>
      )}

      {/* MAIN CONTENT */}
      <div className={`${isDrawerOpen ? 'ml-64' : ''} p-8 transition-all`}>
        {/* HEADER */}
        <div className="flex justify-between items-center mb-8">
          <button onClick={() => setIsDrawerOpen(true)} className="lg:hidden">
            <Menu size={28} />
          </button>
          <h1 className="text-4xl font-bold text-primary">Dashboard</h1>
          <div className="flex items-center gap-4">
            <button onClick={() => setIsDark(!isDark)} className="p-2 rounded-full hover:bg-gray-200 dark:hover:bg-gray-700">
              {isDark ? <Sun size={20} /> : <Moon size={20} />}
            </button>
            <button className="p-2 rounded-full hover:bg-gray-200 dark:hover:bg-gray-700"><Bell size={20} /></button>
            <div className="w-10 h-10 bg-blue-500 rounded-full flex items-center justify-center text-white font-bold">
              {user?.name?.[0] || 'U'}
            </div>
          </div>
        </div>

        {/* QUICK REPORT */}
        <div className="bg-white dark:bg-gray-800 p-6 rounded-2xl shadow-xl mb-8">
          <div className="flex flex-wrap gap-4 items-center">
            <div className="flex items-center gap-2">
              <FileText size={20} className="text-primary" />
              <span className="font-semibold">Quick Report:</span>
            </div>
            <select value={reportType} onChange={(e) => setReportType(e.target.value as any)} className="select select-bordered select-sm">
              <option value="sales">Sales Report</option>
              <option value="cashSales">Cash Sales</option>
              <option value="production">Production</option>
            </select>
            <select value={reportPeriod} onChange={(e) => setReportPeriod(e.target.value as any)} className="select select-bordered select-sm">
              <option value="yesterday">Yesterday</option>
              <option value="lastWeek">Last Week</option>
              <option value="lastMonth">Last Month</option>
              <option value="lastQuarter">Last Quarter</option>
            </select>
            <button onClick={exportToCSV} className="btn btn-sm btn-success flex items-center gap-1">
              <Download size={16} /> Export
            </button>
          </div>
        </div>

        {/* STATS */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
          {[
            { label: 'Revenue', value: '₦125,000', color: 'text-green-600', bg: 'bg-green-50 dark:bg-green-900/20' },
            { label: 'Expenses', value: '₦85,000', color: 'text-red-600', bg: 'bg-red-50 dark:bg-red-900/20' },
            { label: 'Profit', value: '₦40,000', color: 'text-blue-600', bg: 'bg-blue-50 dark:bg-blue-900/20' },
          ].map(stat => (
            <div key={stat.label} className={`${stat.bg} p-6 rounded-2xl shadow-xl`}>
              <h3 className={`text-lg font-semibold ${stat.color}`}>{stat.label}</h3>
              <p className="text-3xl font-bold mt-2">{stat.value}</p>
            </div>
          ))}
        </div>

        {/* LIVE CHARTS */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">
          <div className="bg-white dark:bg-gray-800 p-6 rounded-2xl shadow-xl">
            <h3 className="text-xl font-bold mb-4 flex items-center gap-2">
              <TrendingUp size={20} /> {reportType.charAt(0).toUpperCase() + reportType.slice(1)} Trend
            </h3>
            <ResponsiveContainer width="100%" height={300}>
              <LineChart data={filteredData}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="name" />
                <YAxis />
                <Tooltip />
                <Line type="monotone" dataKey="value" stroke="#3b82f6" strokeWidth={3} dot={{ fill: '#3b82f6' }} />
              </LineChart>
            </ResponsiveContainer>
          </div>
          <div className="bg-white dark:bg-gray-800 p-6 rounded-2xl shadow-xl">
            <h3 className="text-xl font-bold mb-4">Breakdown</h3>
            <ResponsiveContainer width="100%" height={300}>
              <PieChart>
                <Pie data={pieData} cx="50%" cy="50%" outerRadius={100} dataKey="value" label>
                  {pieData.map((_, index) => (
                    <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                  ))}
                </Pie>
                <Tooltip />
              </PieChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* ACTIONS */}
        <div className="flex flex-wrap gap-4">
          <button onClick={exportToCSV} className="btn btn-success flex items-center gap-2">
            <Download size={20} /> Export Report
          </button>
          <button onClick={startQRScanner} className="btn btn-info flex items-center gap-2">
            <QrCode size={20} /> Scan QR
          </button>
          <button onClick={printReceipt} className="btn btn-warning flex items-center gap-2">
            <Printer size={20} /> Print Receipt
          </button>
        </div>
      </div>

      {/* MONEY CALCULATOR */}
      <button
        onClick={() => {
          setShowCalc(!showCalc)
          playSound()
        }}
        className="fixed bottom-24 right-8 w-16 h-16 bg-gradient-to-br from-green-500 to-emerald-600 text-white rounded-full shadow-2xl flex items-center justify-center hover:scale-110 transition-all z-50 border-4 border-white dark:border-gray-800"
      >
        <DollarSign size={28} strokeWidth={3} />
      </button>

      {showCalc && (
        <div
          id="money-calc"
          className="fixed bottom-44 right-8 w-96 bg-gradient-to-br from-white to-gray-50 dark:from-gray-800 dark:to-gray-900 p-6 rounded-3xl shadow-2xl z-50 border border-gray-200 dark:border-gray-700 transform transition-all duration-300"
          style={{ boxShadow: '0 25px 50px -12px rgba(0, 0, 0, 0.25)', maxHeight: '80vh', overflowY: 'auto' }}
        >
          <div className="flex justify-between items-center mb-5 pb-3 border-b border-gray-200 dark:border-gray-700">
            <h3 className="text-2xl font-bold bg-gradient-to-r from-green-600 to-emerald-600 bg-clip-text text-transparent">
              Money Calculator
            </h3>
            <button onClick={() => setShowCalc(false)} className="text-gray-400 hover:text-red-500 transition p-1">
              <X size={26} />
            </button>
          </div>

          <div className="flex gap-1 mb-5 bg-gray-100 dark:bg-gray-700 p-1 rounded-xl">
            {Object.entries(CURRENCIES).map(([code, { symbol }]) => (
              <button
                key={code}
                onClick={() => setCurrency(code as any)}
                className={`flex-1 py-2.5 px-4 rounded-lg text-sm font-bold transition-all ${
                  currency === code
                    ? 'bg-white dark:bg-gray-800 text-green-600 shadow-lg'
                    : 'text-gray-600 dark:text-gray-300'
                }`}
              >
                {symbol} {code}
              </button>
            ))}
          </div>

          <div className="grid grid-cols-2 gap-4 mb-5">
            {CURRENCIES[currency].rates.map(denom => (
              <div key={denom} className="bg-gray-50 dark:bg-gray-700 rounded-2xl p-4 border border-gray-200 dark:border-gray-600 hover:border-green-400 dark:hover:border-emerald-500 transition">
                <p className="text-sm font-mono text-gray-500 dark:text-gray-400 mb-1">
                  {CURRENCIES[currency].symbol}{denom.toLocaleString()}
                </p>
                <input
                  type="number"
                  min="0"
                  value={denomCounts[denom] || ''}
                  onChange={(e) => {
                    setDenomCounts(prev => ({ ...prev, [denom]: Number(e.target.value) || 0 }))
                    playSound()
                  }}
                  className="input input-bordered input-lg w-full text-center font-mono text-2xl font-bold bg-white dark:bg-gray-800"
                  placeholder="0"
                  style={{ height: '56px' }}
                />
                <p className="text-sm font-bold mt-2 text-right text-green-600 dark:text-emerald-400">
                  {CURRENCIES[currency].symbol}{(denom * (denomCounts[denom] || 0)).toLocaleString()}
                </p>
              </div>
            ))}
          </div>

          <div className="bg-gradient-to-r from-green-50 to-emerald-50 dark:from-gray-700 dark:to-gray-800 rounded-2xl p-5 border border-green-200 dark:border-emerald-800">
            <div className="flex justify-between items-center mb-3">
              <span className="text-lg font-bold text-gray-700 dark:text-gray-200">Total Amount</span>
              <span className="text-3xl font-black bg-gradient-to-r from-green-600 to-emerald-600 bg-clip-text text-transparent">
                {CURRENCIES[currency].symbol}{totalAmount.toLocaleString()}
              </span>
            </div>
            <div className="flex gap-3">
              <button onClick={copyTotal} className="flex-1 btn btn-lg btn-success font-bold">
                <Copy size={20} /> Copy
              </button>
              <button onClick={resetCalc} className="flex-1 btn btn-lg btn-error font-bold">
                <RotateCcw size={20} /> Reset
              </button>
            </div>
          </div>
        </div>
      )}

      {/* WORKFLOW LAUNCHER */}
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
    </div>
  )
}