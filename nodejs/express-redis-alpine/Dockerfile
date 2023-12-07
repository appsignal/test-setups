FROM node:18-alpine

# Update this if the docker image changes
ENV REFRESHED_AT=2022-01-25

# Install mono and setup script dependencies
RUN apk add --no-cache ruby bash git curl

# Disable safe directory checks on newer Git
RUN git config --global --add safe.directory '*'

# Install integration build dependencies
RUN apk add --no-cache python3 make g++

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
