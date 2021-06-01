FROM ruby:3.0

# Update this if the docker image changes
ENV REFRESHED_AT=2021-02-12

RUN gem update --system && gem install bundler

# Copy commands into the container
RUN mkdir /commands
COPY ./commands/* /commands/
RUN chmod +x /commands/*

# Run the app
CMD /commands/boot.sh
