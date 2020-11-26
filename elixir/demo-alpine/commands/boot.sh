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

echo "Running app"
cd /app && mix phx.server
