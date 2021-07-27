FROM php:7.2.34-fpm

RUN apt-get update \
  && apt-get install -y libpng-dev libjpeg-dev libpq-dev libwebp-dev libwebp6 webp libmagickwand-dev \
  && apt-get install -y libxml2-dev git unzip mariadb-client \
  && pecl install imagick \
  && docker-php-ext-configure gd --with-freetype-dir=/usr --with-png-dir=/usr --with-jpeg-dir=/usr --with-webp-dir \
  && docker-php-ext-install gd mbstring opcache pdo pdo_mysql pdo_pgsql zip \
  && docker-php-ext-enable imagick \
  && rm -rf /var/lib/apt/lists/*

# composer
RUN curl --silent --show-error https://getcomposer.org/installer | php \
  && mv composer.phar /usr/local/bin/composer \
  && composer --version

# drush
RUN composer global require consolidation/cgr \
  && export PATH="$HOME/.composer/vendor/bin:$PATH" \
  && echo "export PATH=\"$HOME/.composer/vendor/bin:$PATH\"" >> ~/.bashrc \
  && cgr drush/drush:8.x

# redis
RUN pecl install redis

# logs
RUN touch /var/log/php_errors.log && chown www-data:www-data /var/log/php_errors.log

WORKDIR /var/www
