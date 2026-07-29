#!/bin/sh

set -eu

export DATABASE_URL="ecto://postgres@localhost/phoenix_dev"
export PORT=4001
export APPSIGNAL_APP_NAME=elixir-phoenix
export APPSIGNAL_LOG_LEVEL=trace

# Load environment variables from env files
if [ -f /app/appsignal.env ]; then
  set -a
  . /app/appsignal.env
  set +a
fi

if [ -f /app/appsignal_key.env ]; then
  set -a
  . /app/appsignal_key.env
  set +a
fi

cd /app
mix local.hex --force
mix local.rebar --force
mix deps.get
mix ecto.migrate
mix phx.server
