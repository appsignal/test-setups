FROM node:20

# Update this if the docker image changes
ENV REFRESHED_AT=2025-09-22

# TODO Add any required dependencies here
RUN  apt-get update && apt-get install -y ruby

# Update npm
ENV NPM_CONFIG_PREFIX=/home/node/.npm-global
ENV PATH=/home/node/.npm-global/bin:$PATH
RUN mkdir -p $NPM_CONFIG_PREFIX/lib

# Update npm
ENV PATH=/root/mono/bin:$PATH

# Copy commands into the container
RUN mkdir /commands
COPY ./commands/* /commands/
RUN chmod +x /commands/*

# Run the app
CMD /commands/run
