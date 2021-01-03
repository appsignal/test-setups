# TODO: Specify a FROM and required dependencies here

# Copy commands into the container
RUN mkdir /commands
COPY ./commands/*.sh /commands/
RUN chmod +x /commands/*.sh

# Run the app
CMD /commands/boot.sh
