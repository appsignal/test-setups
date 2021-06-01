#!/bin/bash
set -eu

cd /app
bundle exec appsignal diagnose --environment development --send-report
