FROM ruby:3.2.2-bullseye

# Update this if the docker image changes
ENV REFRESHED_AT=2024-12-17

RUN apt-get update && apt-get install -y less

RUN gem update --system && gem install bundler

# Copy commands into the container
RUN mkdir /commands
COPY ./commands/* /commands/
RUN chmod +x /commands/*

# Run the app
CMD /commands/run
