FROM elixir:1.14.1

# Update this if the docker image changes
ENV REFRESHED_AT=2023-01-11

RUN apt-get update && apt-get install -y less

# Copy commands into the container
RUN mkdir /commands
COPY ./commands/* /commands/
RUN chmod +x /commands/*

# Run the app
CMD /commands/run
