FROM rust:1.63.0-alpine3.16

ENV VERSION=0.4.1

RUN apk update
RUN apk add musl-dev

RUN cargo install processmon --version=$VERSION --target=x86_64-unknown-linux-musl
