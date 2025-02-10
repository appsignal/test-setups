import { trace, SpanStatusCode } from "@opentelemetry/api"
import { NextFunction } from "express"

export function expressErrorHandler() {
  return function (
    err: Error & { status?: number },
    req: any,
    res: any,
    next: NextFunction
  ) {
    if (!err.status || err.status >= 500) {
      setError(err)
    }

    return next(err)
  }
}

function setError(error: Error) {
  if (error && error.name && error.message) {
    const activeSpan = trace.getActiveSpan()
    if (activeSpan) {
      activeSpan.recordException(error)
      activeSpan.setStatus({
        code: SpanStatusCode.ERROR,
        message: error.message
      })
    } else {
      console.log(`There is no active span, cannot set \`${error.name}\``)
    }
  } else {
    console.log("Cannot set error, it is not an `Error`-like object")
  }
}
