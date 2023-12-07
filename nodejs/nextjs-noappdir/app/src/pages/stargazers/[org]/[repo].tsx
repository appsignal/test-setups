import { useState, useEffect } from 'react'
import { useRouter } from 'next/router'

export default function Profile() {
  const router = useRouter()
  const [data, setData] = useState(null)
  const [isLoading, setLoading] = useState(true)

  useEffect(() => {
    fetch(`https://api.github.com/repos/${router.query.org}/${router.query.repo}`)
      .then((res) => res.json())
      .then((data) => {
        setData(data)
        setLoading(false)
      })
  })

  if (isLoading) return <p>Loading...</p>
  if (!data) return <p>No repo data</p>

  return (
    <div>
      <h1>Stargazers on {data["full_name"]}: {data["stargazers_count"]}</h1>
    </div>
  )
}
