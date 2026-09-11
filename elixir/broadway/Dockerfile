FROM elixir:1.20.4

# Update this if the docker image changes
ENV REFRESHED_AT=2026-09-11

# Add any required dependencies here
RUN apt-get update && apt-get install -y less

# Copy commands into the container
RUN mkdir /commands
COPY ./commands/* /commands/
RUN chmod +x /commands/*

# Run the app
CMD /commands/run
