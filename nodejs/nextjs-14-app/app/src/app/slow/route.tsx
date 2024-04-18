import { NextResponse } from 'next/server'

async function getData() {
  await new Promise((resolve) => setTimeout(resolve, 3000))
  return {
    props: {}
  }
}

export async function GET(request: Request) {
  const data = await getData()

  return NextResponse.json({ "body": "Well, that took forever!" })
}
