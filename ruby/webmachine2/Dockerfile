FROM ruby:3.2.2-bullseye

# Update this if the docker image changes
ENV REFRESHED_AT=2025-12-12

RUN apt-get update && apt-get install -y less

RUN gem update --system '3.7.2' && gem install bundler -v '2.7.2'

# Copy commands into the container
RUN mkdir /commands
COPY ./commands/* /commands/
RUN chmod +x /commands/*

# Run the app
CMD /commands/run
