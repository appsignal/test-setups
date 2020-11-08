#!/bin/sh

# Install dependencies
cd /app && bundle install --path=vendor/bundle
cd /app && npm install --prefix=vendor/npm

# Clean tmp
rm -rf /app/tmp

# Run app
cd /app && bin/rails server -b 0.0.0.0
