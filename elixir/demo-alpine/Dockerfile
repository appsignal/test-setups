ARG ALPINE_VERSION=3.9

FROM elixir:1.10-alpine

RUN apk update && \
    apk upgrade --no-cache && \
    apk add --no-cache \
      build-base \
      bash \
      openssl-dev \
      netcat-openbsd \
      git \
      alpine-sdk \
      coreutils \
      inotify-tools \
      nodejs \
      npm

RUN mkdir /commands
COPY ./commands/*.sh /commands/
RUN chmod +x /commands/*.sh

CMD /commands/boot.sh
