import Appsignal from "@appsignal/javascript";
const frontEndKey = process.env.REACT_APP_APPSIGNAL_FRONTEND_KEY;

const appSignal = new Appsignal({
  key: frontEndKey,
});

export default appSignal;
