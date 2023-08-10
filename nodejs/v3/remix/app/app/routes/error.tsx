import { useLoaderData } from "@remix-run/react";
import { json } from "@remix-run/node";
import assert from "assert";

export const loader = () => {
  // This'll throw an error
  assert(false)

  return json({
    error: "foo"
  });
}

export default function Error() {
  const data = useLoaderData<typeof loader>();

  return (
    <div>
      {data.error}
    </div>
  )
}
