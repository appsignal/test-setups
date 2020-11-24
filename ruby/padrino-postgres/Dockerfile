FROM ruby:2.7

RUN apt-get update -qq && \
    apt-get install -y nodejs npm postgresql-client

RUN mkdir /commands
COPY ./commands/*.sh /commands/
RUN chmod +x /commands/*.sh

EXPOSE 3000

CMD /commands/setup.sh
