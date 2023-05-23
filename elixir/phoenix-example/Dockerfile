FROM elixir:1.14.1

# Update this if the docker image changes
ENV REFRESHED_AT=2022-10-27

# Install tini
RUN apt-get update
RUN apt-get install tini

# Install node 12
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -
RUN apt-get -y install nodejs

# Copy commands into the container
RUN mkdir /commands
COPY ./commands/* /commands/
RUN chmod +x /commands/*

# Run the app
CMD /commands/run
