#!/bin/sh

echo "Running mix local hex and rebar"
mix local.hex --force
mix local.rebar --force

echo "Running mix deps.get"
cd /app && mix deps.get

echo "Running npm install"
cd /app/assets && npm install

echo "Migrate if needed"
cd /app && mix ecto.migrate

echo "Running phoenix server"
cd /app && mix phx.server
