import { createApp } from 'vue'
import App from './App.vue'

import Appsignal from "@appsignal/javascript"
import { errorHandler } from "@appsignal/vue"

const appsignal = new Appsignal({
  key: process.env.VUE_APP_APPSIGNAL_FRONTEND_KEY
})

const app = createApp(App)
app.config.errorHandler = errorHandler(appsignal, app)
app.mount('#app')
