FROM node:20

# Update this if the docker image changes
ENV REFRESHED_AT=2024-12-17

# Install dependencies
RUN apt-get update && apt-get install -y ruby less

# Update npm
ENV NPM_CONFIG_PREFIX=/home/node/.npm-global
ENV PATH=/home/node/.npm-global/bin:$PATH
# npm@12 dropped Node 20; pin to npm@11, the last line that supports it.
RUN mkdir -p $NPM_CONFIG_PREFIX/lib && npm install -g npm@11

# Configure mono
ENV PATH=/root/mono/bin:$PATH

# Copy commands into the container
RUN mkdir /commands
COPY ./commands/* /commands/
RUN chmod +x /commands/*

# Run prepare and start processmon
CMD /commands/run

ARG NODE_ENV=development
ENV NODE_ENV=$NODE_ENV
