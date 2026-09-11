FROM elixir:1.17.3-otp-27

# Update this if the docker image changes
ENV REFRESHED_AT=2026-09-10

RUN apt-get update && apt-get install -y less

# Copy commands into the container
RUN mkdir /commands
COPY ./commands/* /commands/
RUN chmod +x /commands/*

# Run the app
CMD /commands/run
