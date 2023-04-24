export async function GET(request: Request) {
  const response = await fetch("https://google.com/foobar?baz")
  return new Response(`Fetch replied with status code ${response.status}`)
}
