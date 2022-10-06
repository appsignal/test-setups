const { copyFileSync } = require("fs");
const esbuild = require("esbuild");

// Run esbuild to build the app
esbuild.build({
  entryPoints: ["src/app.js"],
  bundle: true,
  format: "esm",
  platform: "node",
  external: ["@appsignal/nodejs"],
  minify: true,
  keepNames: true,
  sourcemap: true,
  outfile: "dist/app.js",
  define: {
    "APPSIGNAL_APP_NAME": JSON.stringify(process.env.APPSIGNAL_APP_NAME),
    "APPSIGNAL_APP_ENV": JSON.stringify(process.env.APPSIGNAL_APP_ENV),
    "APPSIGNAL_PUSH_API_KEY": JSON.stringify(process.env.APPSIGNAL_PUSH_API_KEY)
  }
}).catch(() =>
  process.exit(1)
);
