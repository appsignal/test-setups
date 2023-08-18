import { useRouter } from 'next/router'
import { useState, useEffect } from 'react'

export default function Page() {
  const router = useRouter()
  // This uses a query param to determine if it will throw an error.
  // The dynamic nature of this condition will make Next.js render it in the
  // browser, rather than optimize it and prerender it on the server side.
  // Without this condition it would be reported as a server error.
  if (router.query.error == "yes") {
    throw new Error("Whoops!")
  }
  return (
    <h1>Uh oh.. I should have thrown an error instead. Use <a href="?error=yes">?error=yes</a> for this route.</h1>
  )
}
