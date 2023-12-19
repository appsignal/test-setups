FROM ruby:3.2-alpine3.19

# Update this if the docker image changes
ENV REFRESHED_AT=2023-06-22

RUN apk add nodejs npm git build-base bash

# RUN apk add alpine-sdk coreutils bash

# Copy commands into the container
RUN mkdir /commands
COPY ./commands/* /commands/
RUN chmod +x /commands/*

# Run the app
CMD /commands/run
