#!/bin/sh

set -eu

rm -f processmon
docker build -t processmon:latest .
docker run --rm -i -v ${PWD}:/mount processmon:latest sh -s <<EOF
  cp /usr/local/cargo/bin/processmon /mount/
EOF
