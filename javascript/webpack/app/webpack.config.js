const webpack = require("webpack");
const path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const { CleanWebpackPlugin } = require('clean-webpack-plugin');
const { AppsignalPlugin } = require("@appsignal/webpack");
const fs = require("fs");

const APPSIGNAL_APP_NAME = process.env.APPSIGNAL_APP_NAME;
const APPSIGNAL_REVISION = fs.readFileSync("REVISION", "utf8").trim();
const port = process.env.PORT;

module.exports = {
  mode: "development",
  entry: './src/index.js',
  output: {
    filename: 'main.js',
    path: path.resolve(__dirname, 'dist'),
    publicPath: '/',
  },
  devtool: "source-map",
  devServer: {
    host: "0.0.0.0",
    contentBase: './dist',
    writeToDisk: true,
    port
  },
  plugins: [
    new CleanWebpackPlugin({}),
    new HtmlWebpackPlugin({
      title: "Webpack example app",
      template: "src/index.html"
    }),
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
};
