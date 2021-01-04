FROM ruby:2.7

# Update this if the docker image changes
ENV REFRESHED_AT=2021-01-04

RUN apt-get update -qq && \
    apt-get install -y nodejs npm postgresql-client

# Copy commands into the container
RUN mkdir /commands
COPY ./commands/*.sh /commands/
RUN chmod +x /commands/*.sh

# Run the server
CMD /commands/boot.sh
