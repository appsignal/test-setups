FROM jruby:9.2

# Update this if the docker image changes
ENV REFRESHED_AT=2021-04-20

RUN apt-get update && apt-get install -y git less

# Copy commands into the container
RUN mkdir /commands
COPY ./commands/* /commands/
RUN chmod +x /commands/*

# Run prepare and run task
CMD /commands/run
