FROM ruby:3.3

# Update this if the docker image changes
ENV REFRESHED_AT=2026-08-19

# procps provides `ps`, handy when comparing the numbers this app reports
# against what the operating system sees.
RUN apt-get update && apt-get install -y less procps

# Copy commands into the container
RUN mkdir /commands
COPY ./commands/* /commands/
RUN chmod +x /commands/*

# Run the app
CMD /commands/run
