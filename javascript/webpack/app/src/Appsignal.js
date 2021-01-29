import Appsignal from "@appsignal/javascript"; // For ES Module
import { plugin } from "@appsignal/plugin-window-events"

const appsignal = new Appsignal({
  name: APPSIGNAL_APP_NAME,
  key: APPSIGNAL_FRONTEND_API_KEY,
  revision: APPSIGNAL_REVISION
});
appsignal.use(plugin({}));

export default appsignal;
