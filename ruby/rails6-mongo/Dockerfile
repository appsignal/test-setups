FROM ruby:3.0.3

# Update this if the Docker image changes
ENV REFRESHED_AT=2022-02-01

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
