FROM ruby:3.2.2-alpine3.19

# Update this if the docker image changes
ENV REFRESHED_AT=2023-12-15

RUN apk add --no-cache alpine-sdk coreutils less

# Copy commands into the container
RUN mkdir /commands
COPY ./commands/* /commands/
RUN chmod +x /commands/*

# Run the app
CMD /commands/run
