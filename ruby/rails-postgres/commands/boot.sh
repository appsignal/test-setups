#!/bin/sh

set -eu

echo "Install appsignal"
cd /integration && rake extension:install

cd /app

echo "Install dependencies"
bundle install --path=vendor/bundle
npm install --prefix=vendor/npm

echo "Clean tmp"
rm -rf tmp

echo "Running migrations"
bin/rails db:migrate
RAILS_ENV=test bin/rails db:create db:migrate

echo "Running rails server"
bin/rails server --binding=0.0.0.0
