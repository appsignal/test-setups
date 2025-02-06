FROM ruby:3.4-bullseye

# Update this if the docker image changes
ENV REFRESHED_AT=2021-02-04

RUN apt-get update -qq && \
    apt-get install -y nodejs npm postgresql-client less

# Copy commands into the container
RUN mkdir /commands
COPY ./commands/* /commands/
RUN chmod +x /commands/*

# Run the app
CMD /commands/run
