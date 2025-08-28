export default function Home() {
  return (
    <div className="items-center justify-items-center min-h-screen p-8 pb-20 gap-16 sm:p-20">
      <h1>Next.js 15 - app router - collector example app</h1>

      <ul>
        <li><a href="/slow">/slow page</a></li>
        <li><a href="/error">/error page</a></li>
      </ul>
    </div>
  );
}
