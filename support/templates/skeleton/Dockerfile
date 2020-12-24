# Specify a FROM and required dependencies here

# Copy commands into the container
RUN mkdir /commands
COPY ./commands/*.sh /commands/
RUN chmod +x /commands/*.sh

# Expose the port that the apps runs on
EXPOSE 3000

# Run the app
CMD /commands/boot.sh
