# PHP with packages to run Drupal 

A Docker image with PHP to run Drupal sites locally.

## Build

* Use DigitalOcean instance to build proper `x86_64` images
* Use following commands to build & push image

```shell
docker login
docker build -f Alpine.Dockerfile -t angarsky/docker-php-drupal:8.4.16-alpine-datadog .
docker push angarsky/docker-php-drupal:8.4.16-alpine-datadog
```

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
