FROM node:15.5-buster

# Update this if the docker image changes
ENV REFRESHED_AT=2021-01-12-9

# Install postgres client
RUN apt-get update
RUN apt-get install -y postgresql-client

# Copy commands into the container
RUN mkdir /commands
COPY ./commands/*.sh /commands/
RUN chmod +x /commands/*.sh

# Run the app
CMD /commands/boot.sh
