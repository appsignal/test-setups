import { Await, useLoaderData } from "@remix-run/react";
import { json } from "@remix-run/node";

export const loader = async () => {
  return json({
    sleep: await new Promise((resolve) => setTimeout(resolve, 3000))
  })
}

export default function Slow() {
  const data = useLoaderData<typeof loader>();

  return (
    <div>
      <p>Waiting...</p>

      <Await resolve={data}>
        {() => <p>Well, that took forever!</p>}
      </Await>
    </div>
  );
}
