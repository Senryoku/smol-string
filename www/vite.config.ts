import { fileURLToPath, URL } from 'node:url'

import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

// https://vitejs.dev/config/
export default defineConfig({
  base: '/smol-string',
  build: {
    target: 'esnext'
  },
  // https://github.com/vitejs/vite/issues/9062
  optimizeDeps: {
    esbuildOptions: { target: 'esnext' }
  },
  plugins: [vue()],
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./src', import.meta.url))
    }
  }
})
