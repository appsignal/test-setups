FROM elixir:1.11.2

# Install node 12
RUN curl -sL https://deb.nodesource.com/setup_12.x  | bash -
RUN apt-get -y install nodejs

# Copy commands into the container
RUN mkdir /commands
COPY ./commands/*.sh /commands/
RUN chmod +x /commands/*.sh

# Run the app
CMD /commands/boot.sh
