#!/bin/sh
set -eu

(
  echo "Install, link and build integration"
  cd /integration
  script/setup
  mono bootstrap
  mono build --package=@appsignal/types,@appsignal/core,@appsignal/vue,@appsignal/javascript,@appsignal/plugin-window-events
)

cd /app

echo "Install dependencies"
yarn install
yarn link @appsignal/types @appsignal/core @appsignal/vue @appsignal/javascript @appsignal/plugin-window-events

echo "Run server"
yarn serve
