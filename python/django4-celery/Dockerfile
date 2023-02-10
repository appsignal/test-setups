FROM python:3.11-buster

# Update this if the docker image changes
ENV REFRESHED_AT=2023-02-08

RUN apt-get update && \
  apt-get install -y postgresql-client git

# Copy commands into the container
RUN mkdir /commands
COPY ./commands/* /commands/
RUN chmod +x /commands/*

# Run the app
CMD /commands/run
