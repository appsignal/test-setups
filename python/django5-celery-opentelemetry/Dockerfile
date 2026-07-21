FROM python:3.11-bullseye

# Update this if the docker image changes
ENV REFRESHED_AT=2023-02-08

RUN apt-get update && \
  apt-get install -y postgresql-client git less

# processmon watches /app and restarts on any file change. Python writes a
# __pycache__ directory into every package it imports, and processmon can only
# ignore __pycache__ directly under the watched path, not at deeper nesting.
# Stop Python writing bytecode so those files never trigger a restart.
ENV PYTHONDONTWRITEBYTECODE=1

# Copy commands into the container
RUN mkdir /commands
COPY ./commands/* /commands/
RUN chmod +x /commands/*

# Run the app
CMD /commands/run
