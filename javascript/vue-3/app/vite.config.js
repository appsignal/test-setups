import { fileURLToPath, URL } from 'node:url'

import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import vueDevTools from 'vite-plugin-vue-devtools'

console.log("my key", process.env.APPSIGNAL_FRONTEND_API_KEY)

// https://vite.dev/config/
export default defineConfig({
  plugins: [
    vue(),
    vueDevTools(),
  ],
  server: {
    allowedHosts: ["app"],
    host: "0.0.0.0",
    port: 4001,
  },
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./src', import.meta.url))
    },
  },
  // define: {
  //   VUE_APP_APPSIGNAL_FRONTEND_KEY: JSON.stringify(process.env.APPSIGNAL_FRONTEND_API_KEY)
  // }
})
