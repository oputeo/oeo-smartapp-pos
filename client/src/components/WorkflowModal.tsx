// src/components/WorkflowModal.tsx
import { X, FileText, DollarSign, Users, Package, Truck, ClipboardList, Send, ShoppingBag, AlertCircle } from 'lucide-react'

interface WorkflowModalProps {
  isOpen: boolean
  onClose: () => void
}

export default function WorkflowModal({ isOpen, onClose }: WorkflowModalProps) {
  if (!isOpen) return null

  const workflows = [
    {
      icon: FileText,
      label: 'Material Request',
      color: 'text-blue-600',
      bg: 'bg-blue-50 dark:bg-blue-900/20',
      action: () => alert('Material Request Form Opened')
    },
    {
      icon: DollarSign,
      label: 'Cash Advance',
      color: 'text-green-600',
      bg: 'bg-green-50 dark:bg-green-900/20',
      action: () => alert('Cash Advance Request Sent')
    },
    {
      icon: Users,
      label: 'Salary Advance',
      color: 'text-purple-600',
      bg: 'bg-purple-50 dark:bg-purple-900/20',
      action: () => alert('Salary Advance Approved')
    },
    {
      icon: Package,
      label: 'Stock Transfer',
      color: 'text-orange-600',
      bg: 'bg-orange-50 dark:bg-orange-900/20',
      action: () => alert('Stock Transfer Initiated')
    },
    {
      icon: Truck,
      label: 'Delivery Note',
      color: 'text-indigo-600',
      bg: 'bg-indigo-50 dark:bg-indigo-900/20',
      action: () => alert('Delivery Note Generated')
    },
    {
      icon: ClipboardList,
      label: 'Purchase Order',
      color: 'text-pink-600',
      bg: 'bg-pink-50 dark:bg-pink-900/20',
      action: () => alert('Purchase Order Created')
    },
    {
      icon: Send,
      label: 'Payment Request',
      color: 'text-teal-600',
      bg: 'bg-teal-50 dark:bg-teal-900/20',
      action: () => alert('Payment Request Submitted')
    },
    {
      icon: ShoppingBag,
      label: 'Sales Invoice',
      color: 'text-rose-600',
      bg: 'bg-rose-50 dark:bg-rose-900/20',
      action: () => alert('Sales Invoice Generated')
    },
  ]

  return (
    <>
      <div
        className="fixed inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center z-50 p-4"
        onClick={onClose}
      >
        <div
          className="bg-white dark:bg-gray-800 rounded-3xl p-8 max-w-2xl w-full mx-4 shadow-2xl transform transition-all duration-300 scale-100"
          style={{
            animation: 'modalPop 0.3s ease-out',
            maxHeight: '90vh',
            overflowY: 'auto'
          }}
          onClick={e => e.stopPropagation()}
        >
          {/* Header */}
          <div className="flex justify-between items-center mb-8 pb-4 border-b border-gray-200 dark:border-gray-700">
            <div>
              <h2 className="text-3xl font-bold bg-gradient-to-r from-indigo-600 to-purple-600 bg-clip-text text-transparent">
                Start Workflow
              </h2>
              <p className="text-sm text-gray-500 dark:text-gray-400 mt-1">
                Choose a process to begin
              </p>
            </div>
            <button
              onClick={onClose}
              className="text-gray-400 hover:text-red-500 transition p-2 rounded-full hover:bg-gray-100 dark:hover:bg-gray-700"
            >
              <X size={28} />
            </button>
          </div>

          {/* Workflow Grid */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {workflows.map((wf, i) => (
              <button
                key={i}
                onClick={() => {
                  wf.action()
                  onClose()
                }}
                className={`${wf.bg} p-5 rounded-2xl hover:scale-105 transition-all duration-200 border border-gray-200 dark:border-gray-700 group`}
                style={{
                  animation: `fadeInUp 0.3s ease-out ${i * 0.05}s both`
                }}
              >
                <div className="flex items-center gap-4">
                  <div className={`p-3 rounded-xl bg-white dark:bg-gray-700 shadow-md group-hover:shadow-lg transition-shadow`}>
                    <wf.icon size={28} className={wf.color} />
                  </div>
                  <div className="text-left">
                    <h3 className="font-bold text-lg text-gray-800 dark:text-gray-100">
                      {wf.label}
                    </h3>
                    <p className="text-xs text-gray-500 dark:text-gray-400">
                      Tap to start
                    </p>
                  </div>
                </div>
              </button>
            ))}
          </div>

          {/* Footer */}
          <div className="mt-8 pt-6 border-t border-gray-200 dark:border-gray-700 flex items-center justify-center gap-2 text-sm text-gray-500 dark:text-gray-400">
            <AlertCircle size={16} />
            <span>All workflows are saved offline</span>
          </div>
        </div>
      </div>

      {/* Global Animation Styles */}
      <style>
        {`
          @keyframes modalPop {
            from {
              opacity: 0;
              transform: scale(0.8);
            }
            to {
              opacity: 1;
              transform: scale(1);
            }
          }
          @keyframes fadeInUp {
            from {
              opacity: 0;
              transform: translateY(20px);
            }
            to {
              opacity: 1;
              transform: translateY(0);
            }
          }
        `}
      </style>
    </>
  )
}