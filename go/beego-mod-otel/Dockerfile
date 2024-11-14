FROM golang:1.23-bullseye

ENV REFRESHED_AT=2024-11-13

RUN apt-get update && apt-get install -y less

# Copy commands into the container
RUN mkdir /commands
COPY ./commands/* /commands/
RUN chmod +x /commands/*

# Run the app
CMD /commands/run
