#!/bin/sh

echo "Install appsignal agent"
cd /integration/ext && ruby extconf.rb && make

echo "Install dependencies"
cd /app && bundle install --path=vendor/bundle
cd /app && npm install --prefix=vendor/npm

echo "Clean tmp"
rm -rf /app/tmp

echo "Run app"
cd /app && bin/rails server -b 0.0.0.0
