ARG ALPINE_VERSION=3.9

FROM elixir:1.13-alpine

# Update this if the docker image changes
ENV REFRESHED_AT=2021-01-04

# Install dependencies that are needed in Alpine
RUN apk update && \
    apk upgrade --no-cache && \
    apk add --no-cache \
      build-base \
      bash \
      openssl-dev \
      netcat-openbsd \
      git \
      make \
      gcc \
      musl-dev \
      musl-utils \
      inotify-tools \
      nodejs \
      npm \
      less

# Copy commands into the container
RUN mkdir /commands
COPY ./commands/* /commands/
RUN chmod +x /commands/*

# Run the app
CMD /commands/prepare && cd /app && /commands/processmon processmon.toml
