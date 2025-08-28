interface ErrorPageProps {
  searchParams: { [key: string]: string | string[] | undefined };
}

export default function ErrorPage({ searchParams }: ErrorPageProps) {
  if (searchParams.error === "yes") {
    throw new Error("This is a test error for AppSignal!");
  }

  return (
    <section>
      <h1>Error page</h1>
      <p>Add <code>?error=yes</code> to the URL to trigger an error</p>
      <p><a href="/error?error=yes">Trigger error</a></p>
    </section>
  );
}
