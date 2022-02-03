import { createApp } from 'vue'
import App from './App.vue'
import router from './router'

import Appsignal from "@appsignal/javascript";
import { errorHandler } from "@appsignal/vue";
import { plugin } from "@appsignal/plugin-window-events"

const appsignal = new Appsignal({
  key: "FRONT-END-KEY",
});
appsignal.use(plugin())

const app = createApp(App)
app.config.errorHandler = errorHandler(appsignal, app)
app.use(router).mount('#app')

