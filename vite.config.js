import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [vue()],
  base: '/image-quality-report-vue3/',
  server: {
    host: '0.0.0.0',
    port: 3000,
    strictPort: true,
    open: true
  },
  build: {},
  optimizeDeps: {
    include: ['xlsx']
  }
})
