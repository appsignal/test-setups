#!/bin/sh
set -eu

(
  echo "Install, link and build integration"
  cd /integration
  script/setup
  mono bootstrap
  mono build --package=@appsignal/types,@appsignal/core,@appsignal/vue,@appsignal/javascript
)

cd /app

echo "Install dependencies"
npm install
npm link @appsignal/types @appsignal/core @appsignal/vue @appsignal/javascript

echo "Run server"
npm run serve
