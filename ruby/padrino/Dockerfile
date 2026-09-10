FROM ruby:2.7

# Update this if the docker image changes
ENV REFRESHED_AT=2026-09-10

# Debian bullseye has moved to the archive, and its release files are past
# their expiry date. There is no image for this Ruby version on a newer
# Debian, so install from the archive and accept the expired release files.
RUN sed -i -e '/-security/d' \
      -e 's|http://deb.debian.org/debian|http://archive.debian.org/debian|g' \
      /etc/apt/sources.list && \
  echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99no-check-valid-until

RUN apt-get update && apt-get install -y less

RUN gem install bundler -v 2.4.22

# Copy commands into the container
RUN mkdir /commands
COPY ./commands/* /commands/
RUN chmod +x /commands/*

ENV BUNDLE_PATH=/app/vendor/bundle

# Run the app
CMD /commands/run
