FROM golang:1.19-bookworm

ENV REFRESHED_AT=2026-09-09

# Copy commands into the container
RUN mkdir /commands
COPY ./commands/* /commands/
RUN chmod +x /commands/*

# Run the app
CMD /commands/run
