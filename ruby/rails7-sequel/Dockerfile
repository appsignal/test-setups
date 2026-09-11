FROM ruby:3.1.2

# Update this if the Docker image changes
ENV REFRESHED_AT=2026-09-10

ENV NODE_MAJOR=18

# Debian bullseye has moved to the archive, and its release files are past
# their expiry date. There is no image for this Ruby version on a newer
# Debian, so install from the archive and accept the expired release files.
RUN sed -i -e '/-security/d' \
      -e 's|http://deb.debian.org/debian|http://archive.debian.org/debian|g' \
      /etc/apt/sources.list && \
  echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99no-check-valid-until

RUN apt-get update && \
  apt-get install -y ca-certificates curl gnupg && \
  mkdir -p /etc/apt/keyrings && \
  curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
  echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list && \
  apt-get update && \
  apt-get install -y nodejs python3 less && \
  npm install -g npm yarn

RUN gem update --system && gem install bundler
ENV BUNDLE_PATH=/app/vendor/bundle

# Copy commands into the container
RUN mkdir /commands
COPY ./commands/* /commands/
RUN chmod +x /commands/*

# Prepare and run
CMD /commands/run
