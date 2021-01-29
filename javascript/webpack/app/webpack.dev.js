const { merge } = require("webpack-merge");
const common = require("./webpack.common.js");

module.exports = merge(common, {
  mode: "development",
  devServer: {
    host: "0.0.0.0",
    contentBase: "./dist",
    writeToDisk: true,
    port
  },
});
