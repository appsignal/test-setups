import Appsignal from "@appsignal/javascript"
import { plugin } from "@appsignal/plugin-window-events"

const bodyData = document.getElementsByTagName("body")[0].dataset
const appsignalInstance = new Appsignal({
  key: bodyData.appsignalkey,
  revision: bodyData.appsignalrevision,
});
appsignalInstance.use(plugin())

export const appsignal = appsignalInstance
