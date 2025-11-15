import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App'
import './index.css'

// Render the full App
const root = document.getElementById('root')
if (root) {
  ReactDOM.createRoot(root).render(
    <React.StrictMode>
      <App />
    </React.StrictMode>
  )
} else {
  console.error('Root element not found in index.html!')
}