FROM node:16.9.1

# Update this if the docker image changes
ENV REFRESHED_AT=2021-09-15

# Install dependencies
RUN apt-get update && apt-get install -y postgresql-client ruby

# Update npm
ENV NPM_CONFIG_PREFIX=/home/node/.npm-global
ENV PATH=/home/node/.npm-global/bin:$PATH
RUN mkdir -p $NPM_CONFIG_PREFIX/lib && npm install -g npm

# Configure mono
ENV PATH=/root/mono/bin:$PATH

# Copy commands into the container
RUN mkdir /commands
COPY ./commands/* /commands/
RUN chmod +x /commands/*

# Run the app
CMD /commands/run
