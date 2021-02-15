FROM ruby:3.0

# Update this if the docker image changes
ENV REFRESHED_AT=2021-02-12

RUN gem update --system && gem install bundler

# Copy commands into the container
RUN mkdir /commands
COPY ./commands/*.sh /commands/
RUN chmod +x /commands/*.sh

ENV BUNDLE_PATH=/app/vendor/bundle

# Run the app
CMD /commands/boot.sh
