FROM node:20

# Update this if the docker image changes
ENV REFRESHED_AT=2024-12-17

# Install dependencies
RUN apt-get update && apt-get install -y ruby less

# Update npm
ENV NPM_CONFIG_PREFIX=/home/node/.npm-global
ENV PATH=/home/node/.npm-global/bin:$PATH
RUN mkdir -p $NPM_CONFIG_PREFIX/lib

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
