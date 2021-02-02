#!/bin/sh

set -eu

cd /app
bundle exec appsignal diagnose --send-report
