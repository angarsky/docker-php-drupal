# PHP with packages to run Drupal 

A Docker image with PHP to run Drupal sites locally.

## Build

`main` holds the PHP 8.x images, one folder per PHP minor version (PHP 7.x lives on the frozen
`7.x` branch):

```
8.4/Dockerfile   8.4/Alpine.Dockerfile
8.5/Dockerfile   8.5/Alpine.Dockerfile
```

Images are built by GitHub Actions
([`.github/workflows/docker-image.yml`](.github/workflows/docker-image.yml)) on `linux/amd64`
runners and pushed to Docker Hub. Each folder produces three tags:

| Tag                     | Source                                         |
|-------------------------|------------------------------------------------|
| `X.Y.Z`                 | `Dockerfile`                                   |
| `X.Y.Z-datadog`         | `Dockerfile` with `--build-arg WITH_DATADOG=1` |
| `X.Y.Z-alpine-datadog`  | `Alpine.Dockerfile`                            |

`X.Y.Z` is read from the `FROM php:X.Y.Z-fpm...` lines. Both Dockerfiles in a folder must use the
same version, and it must match the folder (`8.5/` holds `8.5.*`).

The folders differ where PHP itself differs: in 8.5 OPcache is compiled into PHP, so `8.5/` does
not run `docker-php-ext-install opcache`.

### Releasing a new patch version

1. Dependabot opens one PR per folder when a new patch is out (e.g. `8.5.13` → `8.5.14`).
2. The PR builds and smoke-tests every image of every folder. Nothing is pushed from a PR.
3. Merge the PR. The run on `main` builds, tests and pushes the tags of the folders it changed
   only; the other versions are left untouched.

Changing a Dockerfile without changing the version re-publishes (overwrites) that folder's tags.
To re-publish everything without a code change, use **Actions → Docker image → Run workflow** on
`main`.

### Adding a new minor version (e.g. 8.6)

1. Copy the newest folder to `8.6/` and set both `FROM` lines to `php:8.6.x-fpm` /
   `php:8.6.x-fpm-alpine`.
2. Build it locally (below) and fix what PHP 8.6 changed.
3. Add a `docker` entry for `/8.6` in [`.github/dependabot.yml`](.github/dependabot.yml).
4. Open a PR; merging it publishes the three `8.6.x` tags.

To drop a version, delete its folder and its Dependabot entry. Its tags stay on Docker Hub.

### Security setup (one-time, in the GitHub/Docker Hub UI)

- Docker Hub access token with **Read & Write** scope, stored only as the secret
  `DOCKERHUB_TOKEN` of the GitHub environment `dockerhub`, whose deployment branches are limited to
  `main`. PR runs, including Dependabot and fork PRs, cannot read it.
- Branch ruleset on `main`: pull request required, the `ci` check required (it passes only when
  every build passed), force pushes and deletions blocked.
- Actions settings: only GitHub-owned and `docker/*` actions allowed and pinned to full commit SHAs;
  approval required for workflows from outside contributors; read-only default `GITHUB_TOKEN`.

### Building locally

```shell
docker build -f 8.5/Dockerfile -t php-drupal:test 8.5
docker build -f 8.5/Dockerfile --build-arg WITH_DATADOG=1 -t php-drupal:test-datadog 8.5
docker build -f 8.5/Alpine.Dockerfile -t php-drupal:test-alpine-datadog 8.5
bash .github/scripts/smoke-test.sh php-drupal:test "gd imagick pdo_mysql pdo_pgsql zip"
```

`bash .github/scripts/matrix.sh` prints every image CI would build, with its tag suffix and the
extensions its smoke test requires.

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
