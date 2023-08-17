import { NextResponse } from 'next/server'

export async function GET(
  request: Request,
  { params }: { params: { name: string } }
) {
  return NextResponse.json({ "greeting": `Hello ${params.name}` })
}
