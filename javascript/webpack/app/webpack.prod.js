const webpack = require("webpack");
const { merge } = require("webpack-merge");
const common = require("./webpack.common.js");
const { AppsignalPlugin } = require("@appsignal/webpack");
const fs = require("fs");

const port = process.env.PORT;
const APPSIGNAL_APP_NAME = process.env.APPSIGNAL_APP_NAME;
// Auto increment the revision every time a production build is made
const revisionFile = "REVISION"
const revisionPrefix = "release"
const readRevision = fs.readFileSync(revisionFile, "utf8").trim();
const revisionNumber = Number(readRevision.replace(revisionPrefix, "")) + 1;
const APPSIGNAL_REVISION = `${revisionPrefix}${revisionNumber}`
fs.writeFileSync(revisionFile, APPSIGNAL_REVISION)

module.exports = merge(common, {
  mode: "production",
  plugins: [
    ...common.plugins,
    new webpack.DefinePlugin({
      APPSIGNAL_APP_NAME: JSON.stringify(APPSIGNAL_APP_NAME),
      APPSIGNAL_FRONTEND_API_KEY: JSON.stringify(process.env.APPSIGNAL_FRONTEND_API_KEY),
      APPSIGNAL_REVISION: JSON.stringify(APPSIGNAL_REVISION)
    }),
    new AppsignalPlugin({
      apiKey: process.env.APPSIGNAL_PUSH_API_KEY,
      release: APPSIGNAL_REVISION,
      appName: APPSIGNAL_APP_NAME,
      environment: "development",
      urlRoot: `http://localhost:${port}`
    })
  ]
});
