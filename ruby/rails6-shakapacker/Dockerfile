FROM ruby:3.2.2-bullseye

# Update this if the docker image changes
ENV REFRESHED_AT=2023-06-23

ARG TESTING
ENV TESTING=$TESTING

RUN apt-get update && \
  curl -sL https://deb.nodesource.com/setup_16.x | bash - && \
  apt-get install -y nodejs python2 && \
  npm install -g npm && \
  npm install -g yarn

RUN gem update --system && gem install bundler
ENV BUNDLE_PATH=/app/vendor/bundle

# Copy commands into the container
RUN mkdir /commands
COPY ./commands/* /commands/
RUN chmod +x /commands/*

# Prepare and run
CMD /commands/run
