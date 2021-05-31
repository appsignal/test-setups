const { appsignal } = require("./appsignal");

const {
  getRequestHandler,
  EXPERIMENTAL: { getWebVitalsHandler },
} = require("@appsignal/nextjs");

const url = require("url");
const next = require("next");
const { createServer } = require("http");

const PORT = parseInt(process.env.PORT, 10) || 3000;

const dev = process.env.NODE_ENV !== "production";
const app = next({ dev });
const handle = getRequestHandler(appsignal, app);
const vitals = getWebVitalsHandler(appsignal);

app.prepare().then(() => {
  createServer((req, res) => {
    // Be sure to pass `true` as the second argument to `url.parse`.
    // This tells it to parse the query portion of the URL.
    const parsedUrl = url.parse(req.url, true);
    const { pathname, query } = parsedUrl;

    if (pathname === "/__appsignal-web-vitals") {
      vitals(req, res);
    } else {
      handle(req, res, parsedUrl);
    }
  }).listen(PORT, (err) => {
    if (err) throw err;
    console.log(`> Ready on http://localhost:${PORT}`);
  });
});
