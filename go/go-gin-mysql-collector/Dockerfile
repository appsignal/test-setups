FROM golang:1.24-bookworm

ENV REFRESHED_AT=2025-02-28

# Copy commands into the container
RUN mkdir /commands
COPY ./commands/* /commands/
RUN chmod +x /commands/*

# Run the app
CMD /commands/run
