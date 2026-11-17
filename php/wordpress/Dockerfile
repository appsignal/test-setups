FROM wordpress:php8.4-apache

RUN apt-get update && apt-get install -y unzip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install install-php-extensions
ADD --chmod=0755 https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

# Install OpenTelemetry PHP extension using install-php-extensions
RUN install-php-extensions opentelemetry

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Load AppSignal before every PHP script
COPY docker/appsignal.ini /usr/local/etc/php/conf.d/appsignal.ini

# WP-CLI installs the site on boot, so the setup wizard can be skipped
ADD --chmod=0755 https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar /usr/local/bin/wp

# WordPress only supports MySQL out of the box, use this official plugin
# to store data in an SQLite file
ENV SQLITE_PLUGIN_PATH=/usr/src/wordpress/wp-content/plugins/sqlite-database-integration
RUN curl -sSL https://downloads.wordpress.org/plugin/sqlite-database-integration.zip -o /tmp/sqlite-plugin.zip \
    && unzip -q /tmp/sqlite-plugin.zip -d /usr/src/wordpress/wp-content/plugins \
    && rm /tmp/sqlite-plugin.zip \
    && sed -e "s|{SQLITE_IMPLEMENTATION_FOLDER_PATH}|/var/www/html/wp-content/plugins/sqlite-database-integration|" \
        -e "s|{SQLITE_PLUGIN}|sqlite-database-integration/load.php|" \
        "$SQLITE_PLUGIN_PATH/db.copy" > /usr/src/wordpress/wp-content/db.php \
    && chown -R www-data:www-data /usr/src/wordpress/wp-content

# Copy startup script
COPY commands/run /commands/run
RUN chmod +x /commands/run

EXPOSE 80

CMD ["/commands/run"]
