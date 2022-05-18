const { resolve } = require('path');
const nodeExternals = require('webpack-node-externals');
const { CleanWebpackPlugin } = require('clean-webpack-plugin');
const ForkTsCheckerWebpackPlugin = require('fork-ts-checker-webpack-plugin');

const rootResolve = pathname => resolve(__dirname, pathname);

module.exports = {
  entry: './server/index.ts',
  mode: 'production',
  optimization: {
    minimize: false,
  },
  output: {
    path: rootResolve('build'),
    filename: 'server.js',
  },
  target: 'node',
  externals: [nodeExternals()],
  module: {
    rules: [
      {
        test: /\.ts|\.tsx$/,
        exclude: /node_modules/,
        use: [{
          loader: 'ts-loader',
          options: {
            transpileOnly: true,
          },
        }],
      },
    ],
  },
  plugins: [
    new CleanWebpackPlugin(),
    new ForkTsCheckerWebpackPlugin(),
  ],
  resolve: {
    extensions: ['*', '.js', '.json', '.jsx', '.d.ts', '.ts', '.tsx'],
    alias: {
      '@': rootResolve('.'),
    },
  },
};
