import Vue from 'vue'
import App from './App.vue'

import Appsignal from "@appsignal/javascript"
import { errorHandler } from "@appsignal/vue"

const appsignal = new Appsignal({
  key: process.env.VUE_APP_APPSIGNAL_FRONTEND_KEY
})

Vue.config.productionTip = false
Vue.config.errorHandler = errorHandler(appsignal, Vue)

new Vue({
  render: function (h) { return h(App) },
}).$mount('#app')
