import { NextResponse } from 'next/server'

async function getData(params: URLSearchParams) {
  if (params.get("error") == "yes") {
    throw new Error("Whoops!")
  }
  return {
    props: { value: Math.random() }
  }
}

export async function GET(request: Request) {
  const { searchParams } = new URL(request.url)
  const data = await getData(searchParams)

  return NextResponse.json({ "body": "I should not be shown, but an error should be shown instead", ...data })
}
