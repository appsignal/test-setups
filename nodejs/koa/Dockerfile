FROM node:15.5-buster

# Update this if the docker image changes
ENV REFRESHED_AT=2021-03-18-1

# Copy commands into the container
RUN mkdir /commands
COPY ./commands/* /commands/
RUN chmod +x /commands/*

# Run the app
CMD /commands/run
