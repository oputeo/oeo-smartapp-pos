const express = require('express')
const path = require('path')
const app = express()
const PORT = process.env.PORT || 3000

// Serve static files from client/dist
app.use(express.static(path.join(__dirname, '../client/dist')))

// API Health Check
app.get('/api/health', (req, res) => {
  res.json({
    status: 'OEO SmartApp LIVE',
    time: new Date().toISOString(),
    handle: '@eric_opute',
    country: 'NG'
  })
})

// SPA Fallback
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, '../client/dist/index.html'))
})

app.listen(PORT, () => {
  console.log(`OEO SmartApp LIVE on PORT ${PORT}`)
  console.log(`Visit: http://localhost:${PORT}`)
})