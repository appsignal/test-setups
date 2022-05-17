FROM elixir:latest

# Update this if the docker image changes
ENV REFRESHED_AT=2022-05-17

# Copy commands into the container
RUN mkdir /commands
COPY ./commands/* /commands/
RUN chmod +x /commands/*

# Run the app
CMD /commands/run
