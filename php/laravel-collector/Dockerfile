FROM php:8.3-fpm

# Update this if the docker image changes
ENV REFRESHED_AT=2023-02-08

RUN apt-get update && \
  apt-get -y install npm

# Copy commands into the container
RUN mkdir /commands
COPY ./commands/* /commands/
RUN chmod +x /commands/*

# Run the app
CMD /commands/run
