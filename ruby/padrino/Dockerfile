FROM ruby:2.7

# Update this if the docker image changes
ENV REFRESHED_AT=2024-06-24

RUN apt-get update && apt-get install -y less

RUN gem install bundler -v 2.4.22

# Copy commands into the container
RUN mkdir /commands
COPY ./commands/* /commands/
RUN chmod +x /commands/*

ENV BUNDLE_PATH=/app/vendor/bundle

# Run the app
CMD /commands/run
