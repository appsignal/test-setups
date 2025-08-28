async function getData() {
  await new Promise((resolve) => setTimeout(resolve, 3000));
  return {
    props: {}
  };
}

export default async function Slow() {
  const data = await getData();

  return (
    <div>
      Well, that took forever!
    </div>
  );
}
