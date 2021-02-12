#!/bin/sh

set -eu

cd /app
bundle install
bundle exec rackup
