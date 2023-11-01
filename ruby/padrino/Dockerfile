FROM ruby:3.0

# Update this if the docker image changes
ENV REFRESHED_AT=2021-02-16

RUN apt-get update && apt-get install -y less

RUN gem update --system && gem install bundler

# Copy commands into the container
RUN mkdir /commands
COPY ./commands/* /commands/
RUN chmod +x /commands/*

ENV BUNDLE_PATH=/app/vendor/bundle

# Run the app
CMD /commands/run
