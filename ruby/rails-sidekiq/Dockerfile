FROM ruby:3.0

# Update this if the docker image changes
ENV REFRESHED_AT=2021-01-23

RUN apt-get update && \
  curl -sL https://deb.nodesource.com/setup_15.x | bash - && \
  apt-get install -y nodejs && \
  npm install -g npm && \
  npm install -g yarn

RUN gem update --system && gem install bundler
ENV BUNDLE_PATH=/app/vendor/bundle

# Copy commands into the container
RUN mkdir /commands
COPY ./commands/*.sh /commands/
RUN chmod +x /commands/*.sh

# Run the app
CMD /commands/boot.sh
