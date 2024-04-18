import { NextResponse } from 'next/server'
import { setTag } from '@appsignal/nodejs'

export async function GET(
  request: Request,
  { params }: { params: { name: string } }
) {
  await fetch("https://google.com")
  return NextResponse.json({ "fetch": "done" })
}
