FROM ruby:3.0

# Update this if the docker image changes
ENV REFRESHED_AT=2021-02-10

# Copy commands into the container
RUN mkdir /commands
COPY ./commands/* /commands/
RUN chmod +x /commands/*

# Run prepare and run task
CMD /commands/run
