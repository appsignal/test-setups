FROM rust:1.49.0-alpine3.11

ENV VERSION=0.3.2

RUN apk update
RUN apk add musl-dev

RUN cargo install processmon --version=$VERSION target=x86_64-unknown-linux-musl
