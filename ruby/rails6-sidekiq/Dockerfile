FROM ruby:3.2.2-bullseye

# Update this if the docker image changes
ENV REFRESHED_AT=2021-02-10

RUN apt-get update && \
  curl -sL https://deb.nodesource.com/setup_18.x | bash - && \
  apt-get install -y nodejs python2 && \
  npm install -g npm yarn

RUN gem update --system && gem install bundler
ENV BUNDLE_PATH=/app/vendor/bundle

# Copy commands into the container
RUN mkdir /commands
COPY ./commands/* /commands/
RUN chmod +x /commands/*

# Prepare and run
CMD /commands/run
