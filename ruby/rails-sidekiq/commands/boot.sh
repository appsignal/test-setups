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

echo "Running migrations"
bin/rails db:migrate

echo "Start app"
bundle exec foreman start
