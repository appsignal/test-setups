export async function GET(request: Request) {
  await new Promise((resolve) => setTimeout(resolve, 3000))
  return new Response('Well, that took forever!')
}
