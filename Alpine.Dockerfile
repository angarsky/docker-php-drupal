# https://docs.docker.com/docker-hub/repos/#pushing-a-docker-container-image-to-docker-hub
FROM php:8.4.16-fpm-alpine

# Libraries
RUN apk add --no-cache \
    freetype-dev \
    libjpeg-turbo-dev \
    libpng-dev \
    libwebp-dev \
    imagemagick-dev \
    imagemagick \
    libxml2-dev \
    oniguruma-dev \
    libzip-dev \
    zip \
    unzip \
    git \
    mariadb-client \
    postgresql-dev \
    $PHPIZE_DEPS \
  && docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg --with-webp \
  && docker-php-ext-install -j$(nproc) gd opcache pdo pdo_mysql pdo_pgsql zip \
  && pecl install imagick redis \
  && docker-php-ext-enable imagick redis \
  && apk del $PHPIZE_DEPS \
  && rm -rf /var/cache/apk/*

# Composer
RUN curl --silent --show-error https://getcomposer.org/installer | php \
  && mv composer.phar /usr/local/bin/composer \
  && composer --version

# Logs
RUN touch /var/log/php_errors.log && chown www-data:www-data /var/log/php_errors.log

# ImageMagick policy fix to allow PDF processing
RUN sed -i -e "s/<\/policymap>/  <!-- Custom by Angarsky -->\n  <policy domain=\"coder\" rights=\"read | write\" pattern=\"PDF\" \/>\n<\/policymap>/g" /etc/ImageMagick-7/policy.xml

# DataDog
RUN curl -LO https://github.com/DataDog/dd-trace-php/releases/latest/download/datadog-setup.php \
  && php datadog-setup.php --php-bin=all --enable-appsec --enable-profiling \
  && rm datadog-setup.php

WORKDIR /var/www
