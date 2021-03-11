#!/bin/sh

rm -f processmon
docker build -t processmon .
docker run -i -v ${PWD}:/mount processmon:latest sh -s <<EOF
  cp /usr/local/cargo/bin/processmon /mount/
EOF
