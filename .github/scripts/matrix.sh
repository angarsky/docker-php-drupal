#!/usr/bin/env bash
# Prints the CI build matrix as JSON: one entry per PHP version folder x image variant.
#
# Usage: bash .github/scripts/matrix.sh [8.4 8.5 ...]
#   With no arguments, every 8.* folder in the repo is used.
#
# Each folder holds Dockerfile (Debian) and Alpine.Dockerfile. Both must use the same
# php:X.Y.Z base image, and X.Y must match the folder name.
set -euo pipefail

if [ "$#" -eq 0 ]; then
  for d in 8.*/; do
    [ -d "$d" ] && set -- "$@" "${d%/}"
  done
fi

# variant | Dockerfile | tag suffix | WITH_DATADOG | extensions the smoke test requires
variants='debian|Dockerfile||0|gd imagick pdo_mysql pdo_pgsql zip
debian-datadog|Dockerfile|-datadog|1|gd imagick pdo_mysql pdo_pgsql zip ddtrace
alpine-datadog|Alpine.Dockerfile|-alpine-datadog|1|gd imagick pdo_mysql pdo_pgsql zip redis ddtrace'

fail() { echo "::error::$*" >&2; exit 1; }

# from_version <file> <tag suffix>: prints X.Y.Z from "FROM php:X.Y.Z-<suffix>".
from_version() {
  sed -nE "s/^FROM[[:space:]]+php:([0-9]+\.[0-9]+\.[0-9]+)-$2[[:space:]]*\$/\1/p" "$1" | head -n1
}

entries=''
for dir in "$@"; do
  case "$dir" in
    8.[0-9]*) ;;
    *) fail "Only PHP 8.x folders are supported (got '$dir')" ;;
  esac
  [ -f "$dir/Dockerfile" ] && [ -f "$dir/Alpine.Dockerfile" ] \
    || fail "$dir/ must contain Dockerfile and Alpine.Dockerfile"

  debian=$(from_version "$dir/Dockerfile" fpm)
  alpine=$(from_version "$dir/Alpine.Dockerfile" fpm-alpine)
  [ -n "$debian" ] || fail "$dir/Dockerfile: expected 'FROM php:X.Y.Z-fpm'"
  [ -n "$alpine" ] || fail "$dir/Alpine.Dockerfile: expected 'FROM php:X.Y.Z-fpm-alpine'"
  [ "$debian" = "$alpine" ] || fail "$dir/: PHP versions differ (Dockerfile=$debian, Alpine.Dockerfile=$alpine)"
  case "$debian" in
    "$dir".*) ;;
    *) fail "$dir/: PHP $debian does not belong in folder $dir" ;;
  esac

  while IFS='|' read -r variant dockerfile suffix datadog extensions; do
    entries="$entries${entries:+,}{\"php\":\"$dir\",\"version\":\"$debian\",\"variant\":\"$variant\",\"context\":\"$dir\",\"dockerfile\":\"$dir/$dockerfile\",\"suffix\":\"$suffix\",\"datadog\":\"$datadog\",\"extensions\":\"$extensions\"}"
  done <<EOF
$variants
EOF
done

printf '{"include":[%s]}\n' "$entries"
