import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  root: '.', // ← TELL VITE: index.html is in root
  build: {
    outDir: 'dist',
    emptyOutDir: true,
  },
})