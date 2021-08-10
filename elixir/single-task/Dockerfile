FROM elixir:1.12.2

# Update this if the docker image changes
ENV REFRESHED_AT=2021-08-10

# Copy commands into the container
RUN mkdir /commands
COPY ./commands/* /commands/
RUN chmod +x /commands/*

# Run the app
CMD /commands/run
