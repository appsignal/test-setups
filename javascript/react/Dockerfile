FROM node:15.6

# Update this if the docker image changes
ENV REFRESHED_AT=2021-01-22

# Copy commands into the container
RUN mkdir /commands
COPY ./commands/* /commands/
RUN chmod +x /commands/*

# Run the app
CMD /commands/boot.sh
