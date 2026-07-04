#!/usr/bin/env bash
set -euo pipefail

repo="${OXCAML_OPAM_REPOSITORY_URL:-https://github.com/oxcaml/opam-repository.git}"
ref="${1:-${OXCAML_OPAM_REPOSITORY_REF:-main}}"
compiler_version="${OXCAML_SWITCH:-5.2.0+ox}"
compiler_package="ocaml-variants.${compiler_version}"

if [[ "$ref" =~ ^[0-9a-f]{40}$ ]]; then
  sha="$ref"
else
  sha="$(git ls-remote "$repo" "$ref" "refs/heads/$ref" "refs/tags/$ref" | awk 'NR == 1 { print $1 }')"
fi

if [ -z "${sha:-}" ]; then
  echo "could not resolve OxCaml opam repository ref: $ref" >&2
  exit 1
fi

short_sha="${sha:0:12}"
snapshot_tag="opam-${short_sha}-ubuntu-24.04"

cat <<EOF
opam_sha=$sha
opam_short_sha=$short_sha
compiler_version=$compiler_version
compiler_package=$compiler_package
snapshot_tag=$snapshot_tag
EOF

