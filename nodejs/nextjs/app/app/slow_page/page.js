async function getData() {
  await new Promise((resolve) => setTimeout(resolve, 3000))
  return {
    props: {}
  }
}

export default async function Page() {
  const data = await getData()

  return (
    <h1>Well, that took forever!</h1>
  )
}
