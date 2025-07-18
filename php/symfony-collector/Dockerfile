FROM php:8.2-apache

RUN apt-get update && apt-get install -y \
    git \
    unzip \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

ADD --chmod=0755 https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN install-php-extensions opentelemetry

RUN a2enmod rewrite
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

COPY docker/apache-site.conf /etc/apache2/sites-available/000-default.conf
# COPY docker/php.ini /usr/local/etc/php/conf.d/99-opentelemetry.ini

WORKDIR /var/www/html

COPY commands /commands
RUN chmod +x /commands/run

EXPOSE 80

CMD ["/commands/run"]
