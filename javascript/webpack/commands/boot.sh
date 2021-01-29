#!/bin/sh

set -eu

echo "Install, link and build integration"
cd /integration/packages/javascript
yarn install
yarn build
yarn link

cd /integration/packages/plugin-window-events
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
yarn link @appsignal/plugin-window-events
yarn link @appsignal/webpack
yarn install

echo "Host running"
echo "To update the release used for sourcemaps, update the RELEASE file in: javascript/webpack/RELEASE"
echo "To test the app, run the following command:"
echo "  rake app=javascript/webpack app:console"
echo "Exit this command to stop the server, and run it again to restart the server for a new release."

if [ ! -f REVISION ]; then
  # Create release file with first release version if missing
  echo "release1" > REVISION
fi

tail -f /dev/null # Keep container alive so you can bash into it
