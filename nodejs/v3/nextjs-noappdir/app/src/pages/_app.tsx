import "@/styles/globals.css"
import type { AppProps } from "next/app"
import { appsignal } from "./_appsignal";
import { ErrorBoundary } from "@appsignal/react";

const FallbackComponent = () => (
  <div>Uh oh! There was a client-side error :(</div>
);

export default function App({ Component, pageProps }: AppProps) {
  return (
  <ErrorBoundary
    instance={appsignal}
    tags={{ tag: "value" }}
    fallback={(_error: Error) => <FallbackComponent />}
  >
      <Component {...pageProps} />
    </ErrorBoundary>
  )
}
