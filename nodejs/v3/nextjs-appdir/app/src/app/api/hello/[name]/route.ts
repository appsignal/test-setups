export async function GET(request: Request, { params }: { params: { name: string }}) {
  return new Response(`Hello, ${params.name}!`)
}
