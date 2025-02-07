FROM php:8.3-fpm

# Update this if the docker image changes
ENV REFRESHED_AT=2023-02-08

RUN apt-get update && apt-get install -y \
    build-essential \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    locales \
    zip \
    jpegoptim optipng pngquant gifsicle \
    vim \
    unzip \
    git \
    curl \
    libonig-dev \
    libzip-dev \
    libgd-dev \
    npm

COPY --from=composer /usr/bin/composer /usr/bin/composer
RUN docker-php-ext-install pdo mbstring pcntl
RUN pecl install opentelemetry
RUN echo "[opentelemetry]\nextension=opentelemetry.so\n" > /usr/local/etc/php/php.ini

# Copy commands into the container
RUN mkdir /commands
COPY ./commands/* /commands/
RUN chmod +x /commands/*

ENV PATH=~/.config/composer/vendor/bin:$PATH

# Run the app
CMD /commands/run
