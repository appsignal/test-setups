FROM ruby:3.0

# Update this if the docker image changes
ENV REFRESHED_AT=2021-02-10

RUN apt-get update && apt-get install -y less

# Copy commands into the container
RUN mkdir /commands
COPY ./commands/* /commands/
RUN chmod +x /commands/*

# Run prepare and start processmon
CMD /commands/run
