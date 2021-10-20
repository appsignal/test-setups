#!/bin/sh
set -eu

(
  echo "Install, link and build integration"
  cd /integration
  script/setup
  mono bootstrap
  mono build
)

cd /app

echo "Install dependencies"
yarn install
yarn link @appsignal/vue @appsignal/javascript

echo "Run server"
yarn serve
