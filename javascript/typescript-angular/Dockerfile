FROM node:15.5-buster

# Update this if the docker image changes
ENV REFRESHED_AT=2021-02-01

# Copy commands into the container
RUN mkdir /commands
COPY ./commands/* /commands/
RUN chmod +x /commands/*

RUN npm install -g http-server

# Run the app
CMD /commands/boot.sh
