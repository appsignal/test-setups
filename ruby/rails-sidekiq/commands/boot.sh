#!/bin/sh

set -eu

echo "Install appsignal"
(
  cd /integration
  rake extension:install
)

cd /app
echo "Install dependencies"
bundle install
yarn install

echo "Clean tmp"
rm -rf tmp
mkdir -p tmp/pids tmp/sockets

echo "Running migrations"
bin/rails db:migrate
RAILS_ENV=test bin/rails db:create db:migrate

echo "Start app"
bundle exec foreman start
