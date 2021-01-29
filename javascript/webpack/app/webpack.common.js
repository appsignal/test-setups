const path = require("path");
const HtmlWebpackPlugin = require("html-webpack-plugin");
const { CleanWebpackPlugin } = require("clean-webpack-plugin");

module.exports = {
  entry: {
    app: "./src/index.js",
  },
  output: {
    filename: "index.js",
    path: path.resolve(__dirname, "dist"),
    publicPath: "/",
  },
  devtool: "source-map",
  plugins: [
    new CleanWebpackPlugin({}),
    new HtmlWebpackPlugin({
      title: "Webpack example app",
      template: "src/index.html"
    })
  ]
};
