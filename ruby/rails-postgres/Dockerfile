FROM ruby:2.7

# Update this if the docker image changes
ENV REFRESHED_AT=2021-02-04

RUN apt-get update -qq && \
    apt-get install -y nodejs npm postgresql-client

# Copy commands into the container
RUN mkdir /commands
COPY ./commands/* /commands/
RUN chmod +x /commands/*

# Run prepare and start processmon
CMD /commands/prepare && cd /app && /commands/processmon processmon.toml
