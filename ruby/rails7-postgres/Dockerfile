FROM ruby:3.4

# Update this if the docker image changes
ENV REFRESHED_AT=2026-09-09

RUN apt-get update -qq && \
    apt-get install -y nodejs npm postgresql-client less

# Copy commands into the container
RUN mkdir /commands
COPY ./commands/* /commands/
RUN chmod +x /commands/*

# Run the app
CMD /commands/run
