import { NextResponse } from 'next/server'
import { setTag } from '@appsignal/nodejs'

export async function GET(
  request: Request,
  { params }: { params: { name: string } }
) {
  setTag("test", "blah")
  return NextResponse.json({ "greeting": `Hello ${params.name}` })
}
