import './assets/main.css'

import { createApp } from 'vue'
import App from './App.vue'
import router from './router'
import { appsignal } from "./appsignal";
import { errorHandler } from "@appsignal/vue"

const app = createApp(App)
app.config.errorHandler = errorHandler(appsignal, app)
// app.config.errorHandler = (err, instance, info) => {
//   console.log("!!! error", err, instance, info)
//   // handle error, e.g. report to a service
// }

app.use(router)

app.mount('#app')
