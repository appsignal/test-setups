const { copyFileSync } = require("fs");
const esbuild = require("esbuild");

// Run esbuild to build the frontend assets
esbuild.build({
  entryPoints: ["src/app.js"],
  bundle: true,
  format: "esm",
  minify: true,
  keepNames: true,
  sourcemap: true,
  outfile: "dist/app.js",
  define: {
    // Include AppSignal app front-end key in build assets
    "APPSIGNAL_FRONTEND_KEY": JSON.stringify(process.env.APPSIGNAL_FRONTEND_KEY)
  }
}).then(() => {
  // Copy the static files from the src directory to the dist directory
  // so it can be served by the HTTP server
  const STATIC_FILES = [
    "index.html",
    "something.html",
    "style.css"
  ]

  STATIC_FILES.forEach((filename) =>
    copyFileSync(`src/${filename}`, `dist/${filename}`)
  )
}).catch(() =>
  process.exit(1)
);
