# PHP with packages to run Drupal 

A Docker image with PHP to run Drupal sites locally.

## Usage

This image is based on the official docker PHP-FPM image, extended by Composer, Drush and other packages. 

Example of a ```docker-compose.yml``` file:

```
version: '2'

services:
  php-fpm:
    image: angarsky/docker-php-drupal:7.2.34
    volumes:
      - ./site:/var/www
    container_name: php-fpm
```
