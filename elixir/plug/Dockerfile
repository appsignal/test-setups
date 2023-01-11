# TODO Specify FROM

# Update this if the docker image changes
ENV REFRESHED_AT=2023-01-11

# TODO Add any required dependencies here

# Copy commands into the container
RUN mkdir /commands
COPY ./commands/* /commands/
RUN chmod +x /commands/*

# Run the app
CMD /commands/run
