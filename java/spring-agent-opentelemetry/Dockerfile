FROM gradle:8.5-jdk17

WORKDIR /app

EXPOSE 8080

# Copy commands into the container
RUN mkdir /commands
COPY ./commands/* /commands/
RUN chmod +x /commands/*

CMD /commands/run
