import Appsignal from "@appsignal/javascript";

const key = process.env.NEXT_PUBLIC_APPSIGNAL_FRONTEND_API_KEY
if (!key) {
  console.error("No NEXT_PUBLIC_APPSIGNAL_FRONTEND_API_KEY found! Please add the key to the app's `nodejs/v3/nextjs-noappdir/appsignal_key.env` file")
}
export const appsignal = new Appsignal({
  key
});
