FROM ruby:3.2

# Update this if the docker image changes
ENV REFRESHED_AT=2021-06-22

RUN apt-get update && apt-get install -y less

# Copy commands into the container
RUN mkdir /commands
COPY ./commands/* /commands/
RUN chmod +x /commands/*

# Run the app
CMD /commands/run
