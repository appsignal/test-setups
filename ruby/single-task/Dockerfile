FROM ruby:3.0

# Update this if the docker image changes
ENV REFRESHED_AT=2021-01-19

# Copy commands into the container
RUN mkdir /commands
COPY ./commands/*.sh /commands/
RUN chmod +x /commands/*.sh

# Run the app
CMD /commands/boot.sh
