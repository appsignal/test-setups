const { copyFileSync } = require("fs");
const esbuild = require("esbuild");

// Run esbuild to build the frontend assets
esbuild.build({
  entryPoints: ["src/app.js"],
  bundle: true,
  format: "esm",
  minify: true,
  sourcemap: true,
  outfile: "dist/app.js",
  define: {
    // Include AppSignal app front-end key in build assets
    "APPSIGNAL_FRONTEND_KEY": JSON.stringify(process.env.APPSIGNAL_FRONTEND_KEY)
  }
}).then(() =>
  // Copy the src/index.html file to the dist directory so it can be served by
  // the HTTP server
  copyFileSync("src/index.html", "dist/index.html")
).catch(() =>
  process.exit(1)
);
