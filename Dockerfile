FROM php:7.4.27-fpm

RUN apt-get update \
  && apt-get install -y libpng-dev libjpeg-dev libpq-dev libwebp-dev libwebp6 webp libmagickwand-dev \
  && apt-get install -y libonig-dev libxml2-dev git libzip-dev zip unzip mariadb-client \
  && pecl install imagick \
  && docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg --with-webp \
  && docker-php-ext-install gd opcache pdo pdo_mysql pdo_pgsql zip \
  && docker-php-ext-enable imagick \
  && docker-php-source delete \
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

# ImageMagick policy fix to allow PDF processing
RUN sed -i -e "s/<\/policymap>/  <\!-- Custom by Angarsky -->\\n  <policy domain=\"coder\" rights=\"read \| write\" pattern=\"PDF\" \/>\\n<\/policymap>/g" /etc/ImageMagick-6/policy.xml

WORKDIR /var/www
