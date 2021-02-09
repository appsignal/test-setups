#!/bin/sh

set -eu

echo "Install, link and build integration"
cd /integration/packages/javascript
yarn install
yarn build
yarn link

cd /integration/packages/angular
yarn install
yarn build
yarn link

cd /integration/packages/webpack
yarn install
yarn build
yarn link

# App
cd /app
echo "Install dependencies"
yarn link @appsignal/javascript
yarn link @appsignal/angular
yarn link @appsignal/webpack
yarn install

echo "Host running"
echo "To test the app, run the following command:"
echo "  rake app=javascript/typescript-angular app:console"
echo "Exit the console command to stop the server, and run it again to restart the server for a new release."

if [ ! -f REVISION ]; then
  # Create release file with first release version if missing
  echo "release0" > REVISION
fi

tail -f /dev/null # Keep container alive so you can bash into it
