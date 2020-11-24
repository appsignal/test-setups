#!/bin/sh

echo "Install appsignal agent"
cd /integration/ext && ruby extconf.rb && make

echo "Install dependencies"
cd /app && bundle install --path=vendor/bundle

echo "Run app"
cd /app && bundle exec padrino start -h 0.0.0.0
