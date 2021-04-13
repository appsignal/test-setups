import Link from "next/link"

export default function BlogIndexPage() {
  return (
    <Link
      href={{
        pathname: "/about",
        query: { id: "test" },
      }}
    >
      <a>Blog page</a>
    </Link>
  )
}