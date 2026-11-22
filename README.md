# PHP with packages to run Drupal 

A Docker image with PHP to run Drupal sites locally.

## Build

`main` holds the PHP 8.x images (PHP 7.x lives on the frozen `7.x` branch). Images are built by
GitHub Actions ([`.github/workflows/docker-image.yml`](.github/workflows/docker-image.yml)) on
`linux/amd64` runners and pushed to Docker Hub with these tags:

| Tag                     | Source                                       |
|-------------------------|----------------------------------------------|
| `X.Y.Z`                 | `Dockerfile`                                 |
| `X.Y.Z-datadog`         | `Dockerfile` with `--build-arg WITH_DATADOG=1` |
| `X.Y.Z-alpine-datadog`  | `Alpine.Dockerfile`                          |

`X.Y.Z` is read from the `FROM php:X.Y.Z-fpm...` lines; both Dockerfiles must use the same version.

### Releasing a new PHP version

1. Dependabot opens a PR when a new PHP 8.4.x patch is out (or bump both `FROM` lines yourself
   in a PR, e.g. for a move to 8.5).
2. The PR builds and smoke-tests all three images. Nothing is pushed from a PR.
3. Merge the PR. The run on `main` builds, tests and pushes the three tags.

Changing a Dockerfile without changing the version re-publishes (overwrites) the same tags.
To re-publish without a code change, use **Actions → Docker image → Run workflow** on `main`.

### Security setup (one-time, in the GitHub/Docker Hub UI)

- Docker Hub access token with **Read & Write** scope, stored only as the secret
  `DOCKERHUB_TOKEN` of the GitHub environment `dockerhub`, whose deployment branches are limited to
  `main`. PR runs, including Dependabot and fork PRs, cannot read it.
- Branch ruleset on `main`: pull request required, the `version` and `build (*)` checks required,
  force pushes and deletions blocked.
- Actions settings: only GitHub-owned and `docker/*` actions allowed and pinned to full commit SHAs;
  approval required for workflows from outside contributors; read-only default `GITHUB_TOKEN`.

### Building locally

```shell
docker build -f Dockerfile -t php-drupal:test .
docker build -f Dockerfile --build-arg WITH_DATADOG=1 -t php-drupal:test-datadog .
docker build -f Alpine.Dockerfile -t php-drupal:test-alpine-datadog .
bash .github/scripts/smoke-test.sh php-drupal:test "gd imagick pdo_mysql pdo_pgsql zip"
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
