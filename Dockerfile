# https://docs.docker.com/docker-hub/repos/#pushing-a-docker-container-image-to-docker-hub
FROM php:8.4.16-fpm

# Libraries.
RUN apt-get update \
  && apt-get install -y libpng-dev libjpeg-dev libpq-dev libwebp-dev libwebp7 webp libmagickwand-dev \
  && apt-get install -y libonig-dev libxml2-dev git libzip-dev zip unzip mariadb-client \
  && pecl install imagick \
  && docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg --with-webp \
  && docker-php-ext-install gd opcache pdo pdo_mysql pdo_pgsql zip \
  && docker-php-ext-enable imagick \
  && docker-php-source delete \
  && rm -rf /var/lib/apt/lists/*

# Composer
RUN curl --silent --show-error https://getcomposer.org/installer | php \
  && mv composer.phar /usr/local/bin/composer \
  && composer --version

# Redis
RUN pecl install redis

# Logs
RUN touch /var/log/php_errors.log && chown www-data:www-data /var/log/php_errors.log

# ImageMagick policy fix to allow PDF processing
RUN sed -i -e "s/<\/policymap>/  <\!-- Custom by Angarsky -->\\n  <policy domain=\"coder\" rights=\"read \| write\" pattern=\"PDF\" \/>\\n<\/policymap>/g" /etc/ImageMagick-7/policy.xml

# DataDog
#RUN curl -LO https://github.com/DataDog/dd-trace-php/releases/latest/download/datadog-setup.php \
#  && php datadog-setup.php --php-bin=all --enable-appsec --enable-profiling

WORKDIR /var/www
