#!/bin/sh

echo "Install, link and build integration"
cd /integration && make install
cd /integration && make build

echo "Npm link in app"
cd /app && npm link @appsignal/nodejs
cd /app && npm link @appsignal/nextjs

echo "Install dependencies"
cd /app && npm install

echo "Run express server"
cd /app && npm run dev
