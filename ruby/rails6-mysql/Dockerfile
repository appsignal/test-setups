FROM ruby:3.2.2-bullseye

# Update this if the docker image changes
ENV REFRESHED_AT=2021-02-04
ENV NODE_MAJOR=18

RUN apt-get update && \
  apt-get install -y ca-certificates curl gnupg less && \
  mkdir -p /etc/apt/keyrings && \
  curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
  echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list && \
  apt-get update && \
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
