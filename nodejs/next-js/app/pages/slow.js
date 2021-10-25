export async function getServerSideProps(_context) {
  await new Promise((resolve) => setTimeout(resolve, 3000))
  return {}
}

export default function Slow() {
  return (
    <h1>Well, that took forever!</h1>
  )
}
