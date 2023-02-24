FROM golang:1.18-buster

ENV REFRESHED_AT=2023-02-23

# Copy commands into the container
RUN mkdir /commands
COPY ./commands/* /commands/
RUN chmod +x /commands/*

# Run the app
CMD /commands/run
