FROM ruby:3.3.6

# Update this if the Docker image changes
ENV REFRESHED_AT=2024-11-05
ENV NODE_MAJOR=22

# Add PostgreSQL APT repository
RUN apt-get update && \
    apt-get install -y wget gnupg && \
    mkdir -p /etc/apt/keyrings && \
    wget -qO - https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor -o /etc/apt/keyrings/postgresql.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/postgresql.gpg] http://apt.postgresql.org/pub/repos/apt/ bookworm-pgdg main" | tee /etc/apt/sources.list.d/pgdg.list && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
      echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list

# Update and install packages
RUN apt-get update && \
    apt-get install -y postgresql-client-16 less nodejs python3
RUN gem update --system && gem install bundler

# Copy commands into the container
RUN mkdir /commands
COPY ./commands/* /commands/
RUN chmod +x /commands/*

# Prepare and run
CMD /commands/run
