export async function getServerSideProps(_context: any) {
  throw new Error("Whoops!")
  return {
    props: {}
  }
}

export default function Slow() {
  return (
    <h1>Well, that took forever!</h1>
  )
}
