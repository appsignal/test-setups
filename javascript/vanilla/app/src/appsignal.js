import Appsignal from "@appsignal/javascript";
import { plugin as networkBreadcrumbs } from "@appsignal/plugin-breadcrumbs-network"
import { plugin as consoleBreadcrumbs } from "@appsignal/plugin-breadcrumbs-console"
import { plugin as windowEvents } from "@appsignal/plugin-window-events"
import { plugin as pathDecorator } from "@appsignal/plugin-path-decorator"

const appsignal = new Appsignal({
  key: APPSIGNAL_FRONTEND_KEY
});

appsignal.use(networkBreadcrumbs());
appsignal.use(consoleBreadcrumbs());
appsignal.use(windowEvents());
appsignal.use(pathDecorator());

export default appsignal;

