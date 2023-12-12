FROM rust:1.74.1-alpine3.17

RUN apk update
RUN apk add musl-dev

ENV VERSION=0.4.1
ENV CARGO_REGISTRIES_CRATES_IO_PROTOCOL=sparse

RUN cargo install processmon --version=$VERSION
