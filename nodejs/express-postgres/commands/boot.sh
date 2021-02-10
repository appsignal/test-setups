#!/bin/sh
sleep 5
echo "Create posts table if needed"
psql "postgresql://$POSTGRES_USER:$POSTGRES_PASSWORD@postgres/$POSTGRES_DB" \
  -c "CREATE TABLE IF NOT EXISTS posts (id SERIAL, title varchar(80), text text);"

echo "Install, link and build integration"
cd /integration && make install
cd /integration && make build

echo "Npm link in app"
cd /app && npm link @appsignal/nodejs
cd /app && npm link @appsignal/express

echo "Install dependencies"
cd /app && npm install

echo "Run express server"
cd /app && npx nodemon -e js,pug app.js
