import { Await, useLoaderData } from "@remix-run/react";
import { json, LoaderArgs } from "@remix-run/node";

export const loader = async ({ params }: LoaderArgs) => {
  return json({
    greeting: `Hello ${params.name ?? "world"}!`
  })
}

export default function Slow() {
  const data = useLoaderData<typeof loader>();

  return (
    <div>
      <Await resolve={data}>
        {({greeting}) => <p>{greeting}</p>}
      </Await>
    </div>
  );
}
