FROM elixir:1.16.2

# Update this if the docker image changes
ENV REFRESHED_AT=2024-05-07
ENV NODE_MAJOR=22

RUN apt-get update && \
  apt-get install -y ca-certificates curl gnupg && \
  mkdir -p /etc/apt/keyrings && \
  curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
  echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list && \
  apt-get update && \
  apt-get -y install nodejs less

# Copy commands into the container
RUN mkdir /commands
COPY ./commands/* /commands/
RUN chmod +x /commands/*

# Run the app
CMD /commands/run
