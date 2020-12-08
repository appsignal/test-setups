#!/bin/sh

echo "Running mix local hex and rebar"
mix local.hex --force
mix local.rebar --force

echo "Running mix deps.get"
cd /app && mix deps.get

echo "Running ecto setup"
cd /app && mix ecto.setup

echo "Running npm install"
cd /app/assets && npm install

echo "Digest assets"
cd /app && mix phx.digest

echo "Build a release"
mkdir /tmp/release
export MIX_ENV=prod
export SECRET_KEY_BASE=base
cd /app && mix release --path=/tmp/release

echo "Run the release"
/tmp/release/bin/demo start
