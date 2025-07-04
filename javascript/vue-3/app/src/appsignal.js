import Appsignal from "@appsignal/javascript";

console.log("key", import.meta.env.VITE_APPSIGNAL_FRONTEND_API_KEY)
export const appsignal = new Appsignal({
  key: import.meta.env.VITE_APPSIGNAL_FRONTEND_API_KEY,
  uri: import.meta.env.VITE_APPSIGNAL_FRONTEND_API_ENDPOINT ?? null
});
