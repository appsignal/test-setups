#!/bin/sh

set -eu

echo "Install appsignal"
(
  set -eu
  cd /integration
  rake extension:install
)

echo "Install dependencies"
(
  set -eu
  cd /app
  bundle config set --local path 'vendor/bundle'
  bundle install
)

echo "Start Shoryuken worker"
(
  cd /app
  # Create queues in mock server
  bundle exec shoryuken sqs create default
  bundle exec shoryuken sqs create batched
  # Queue some jobs
  bundle exec ruby app.rb
  # Start worker process
  bundle exec shoryuken --require=$(pwd)/workers.rb --config=shoryuken.yml
)
