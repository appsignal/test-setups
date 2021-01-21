#!/bin/sh

set -eu

echo "Install, link and build integration"
cd /integration
yarn install
yarn build
yarn link:yarn

echo "Npm link in app"
cd /integration/packages/javascript
yarn install
yarn link

# App
cd /app
echo "Install dependencies"
yarn link @appsignal/javascript
yarn install

echo "Run server"
yarn start
