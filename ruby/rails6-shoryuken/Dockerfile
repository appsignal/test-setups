FROM ruby:3.1.1

# Update this if the docker image changes
ENV REFRESHED_AT=2021-03-01

RUN apt-get update

RUN gem update --system && gem install bundler

# Copy commands into the container
RUN mkdir /commands
COPY ./commands/* /commands/
RUN chmod +x /commands/*

# Prepare and run
CMD /commands/run
