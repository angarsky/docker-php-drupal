#!/usr/bin/env bash
# Smoke-tests a built image.
# Usage: bash .github/scripts/smoke-test.sh <image> "<extension> <extension> ..."
set -euo pipefail

image=${1:?usage: smoke-test.sh <image> "<extensions>"}
extensions=${2:-}

docker run --rm "$image" php -v
docker run --rm -e COMPOSER_ALLOW_SUPERUSER=1 "$image" composer --version

# Every listed extension, plus OPcache, must be loaded.
docker run --rm -e EXTENSIONS="$extensions" "$image" php -r '
  $wanted = array_filter(explode(" ", getenv("EXTENSIONS")));
  $missing = array_values(array_filter($wanted, fn ($e) => !extension_loaded($e)));
  if (!extension_loaded("Zend OPcache")) { $missing[] = "opcache"; }
  if ($missing) { fwrite(STDERR, "Missing PHP extensions: " . implode(", ", $missing) . PHP_EOL); exit(1); }
  echo "PHP extensions OK: ", implode(" ", $wanted), " opcache", PHP_EOL;
'

if ! docker run --rm "$image" grep -q 'pattern="PDF"' /etc/ImageMagick-7/policy.xml; then
  echo "ImageMagick PDF policy was not applied" >&2
  exit 1
fi
echo "ImageMagick PDF policy OK"

echo "Smoke test passed: $image"
