#!/usr/bin/env bash
set -euo pipefail

image="${1:?usage: check-image-labels.sh IMAGE EXPECTED_OPAM_SHA [EXPECTED_COMPILER_VERSION]}"
expected_sha="${2:?usage: check-image-labels.sh IMAGE EXPECTED_OPAM_SHA [EXPECTED_COMPILER_VERSION]}"
expected_compiler_version="${3:-}"

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

if [ -n "$expected_compiler_version" ]; then
  actual_compiler_version="$(
    docker image inspect "$image" \
      --format '{{ index .Config.Labels "dev.cezarc1.oxcaml.compiler_version" }}'
  )"

  if [ "$actual_compiler_version" != "$expected_compiler_version" ]; then
    echo "unexpected compiler version label for $image" >&2
    echo "expected: $expected_compiler_version" >&2
    echo "actual:   $actual_compiler_version" >&2
    exit 1
  fi
fi
