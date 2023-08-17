FROM elixir:1.15.4

# Update this if the docker image changes
ENV REFRESHED_AT=2023-08-17

# Copy commands into the container
RUN mkdir /commands
COPY ./commands/* /commands/
RUN chmod +x /commands/*

# Run the app
CMD /commands/run
