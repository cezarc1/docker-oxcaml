#!/usr/bin/env bash
set -euo pipefail

image="${1:?usage: check-image-labels.sh IMAGE EXPECTED_OPAM_SHA}"
expected_sha="${2:?usage: check-image-labels.sh IMAGE EXPECTED_OPAM_SHA}"

docker image inspect "$image" >/dev/null 2>&1 || docker pull "$image" >/dev/null

actual_ref="$(
  docker image inspect "$image" \
    --format '{{ index .Config.Labels "dev.cezarc1.oxcaml.opam_repository_ref" }}'
)"

if [ "$actual_ref" != "$expected_sha" ]; then
  echo "unexpected opam repository ref label for $image" >&2
  echo "expected: $expected_sha" >&2
  echo "actual:   $actual_ref" >&2
  exit 1
fi
