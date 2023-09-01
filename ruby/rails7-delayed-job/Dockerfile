FROM ruby:3.1.3

# Update this if the Docker image changes
ENV REFRESHED_AT=2022-11-07

RUN apt-get update && \
  curl -sL https://deb.nodesource.com/setup_18.x | bash - && \
  apt-get install -y nodejs python3 && \
  npm install -g npm yarn

RUN gem update --system && gem install bundler
ENV BUNDLE_PATH=/app/vendor/bundle

# Copy commands into the container
RUN mkdir /commands
COPY ./commands/* /commands/
RUN chmod +x /commands/*

# Prepare and run
CMD /commands/run
