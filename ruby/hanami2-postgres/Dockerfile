FROM ruby:3.1.2

# Update this if the Docker image changes
ENV REFRESHED_AT=2022-12-20

RUN apt-get update && apt-get -y install postgresql-client less
RUN gem update --system && gem install bundler
ENV BUNDLE_PATH=/app/vendor/bundle

# Copy commands into the container
RUN mkdir /commands
COPY ./commands/* /commands/
RUN chmod +x /commands/*

# Prepare and run
CMD /commands/run
