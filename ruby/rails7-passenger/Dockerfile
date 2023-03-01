FROM ruby:3.1.2-bullseye

# Update this if the Docker image changes
ENV REFRESHED_AT=2022-11-07

RUN apt-get update && \
  curl -sL https://deb.nodesource.com/setup_18.x | bash - && \
  apt-get install -y nodejs python3 && \
  npm install -g npm && \
  npm install -g yarn

RUN gem update --system && gem install bundler
ENV BUNDLE_PATH=/app/vendor/bundle

# Install Passenger's PGP key and add HTTPS support for APT
RUN apt-get install -y dirmngr gnupg apt-transport-https ca-certificates curl

RUN curl https://oss-binaries.phusionpassenger.com/auto-software-signing-gpg-key.txt | gpg --dearmor | tee /etc/apt/trusted.gpg.d/phusion.gpg >/dev/null

# Add Passenger's APT repository
RUN sh -c 'echo deb https://oss-binaries.phusionpassenger.com/apt/passenger bullseye main > /etc/apt/sources.list.d/passenger.list'
RUN apt-get update

# Install Passenger
RUN apt-get install -y passenger

# Validate Passenger installation
RUN /usr/bin/passenger-config validate-install

# Copy commands into the container
RUN mkdir /commands
COPY ./commands/* /commands/
RUN chmod +x /commands/*

# Prepare and run
CMD /commands/run
