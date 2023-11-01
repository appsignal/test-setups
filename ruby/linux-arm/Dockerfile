FROM --platform=linux/arm64/v8 ruby:3.0

# Update this if the docker image changes
ENV REFRESHED_AT=2021-07-06

RUN apt-get update && apt-get install -y less

# Copy commands into the container
RUN mkdir /commands
COPY ./commands/* /commands/
RUN chmod +x /commands/*

# Run the app
CMD /commands/run
