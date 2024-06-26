FROM ruby:3.3.3

# Update this if the Docker image changes
ENV REFRESHED_AT=2024-06-25

RUN apt-get update && apt-get -y install less
RUN gem update --system && gem install bundler

# Copy commands into the container
RUN mkdir /commands
COPY ./commands/* /commands/
RUN chmod +x /commands/*

# Prepare and run
CMD /commands/run
