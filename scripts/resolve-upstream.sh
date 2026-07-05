#!/usr/bin/env bash
set -euo pipefail

repo="${OXCAML_OPAM_REPOSITORY_URL:-https://github.com/oxcaml/opam-repository.git}"
ref="${1:-${OXCAML_OPAM_REPOSITORY_REF:-main}}"

if [[ "$ref" =~ ^[0-9a-f]{40}$ ]]; then
  sha="$ref"
else
  sha="$(git ls-remote "$repo" "$ref" "refs/heads/$ref" "refs/tags/$ref" | awk 'NR == 1 { print $1 }')"
fi

if [ -z "${sha:-}" ]; then
  echo "could not resolve OxCaml opam repository ref: $ref" >&2
  exit 1
fi

tmp_dir="$(mktemp -d)"
cleanup() {
  rm -rf "$tmp_dir"
}
trap cleanup EXIT

git -C "$tmp_dir" init -q
git -C "$tmp_dir" remote add origin "$repo"
git -C "$tmp_dir" fetch -q --depth 1 --filter=blob:none origin "$sha"

variants="$(
  git -C "$tmp_dir" ls-tree --name-only FETCH_HEAD:packages/ocaml-variants |
    sed -n 's/^ocaml-variants\.\([0-9][0-9.]*+ox\)$/\1/p' |
    sort -V
)"

if [ -z "$variants" ]; then
  echo "could not find any ocaml-variants.*+ox packages in $repo at $sha" >&2
  exit 1
fi

if [ -n "${OXCAML_SWITCH:-}" ]; then
  compiler_version="$OXCAML_SWITCH"
  if ! printf '%s\n' "$variants" | grep -Fxq "$compiler_version"; then
    echo "requested OxCaml switch is not present in $repo at $sha: $compiler_version" >&2
    echo "available switches:" >&2
    printf '  %s\n' $variants >&2
    exit 1
  fi
else
  compiler_version="$(printf '%s\n' "$variants" | tail -1)"
fi

compiler_base="${compiler_version%+ox}"
compiler_major_minor="${compiler_base%.*}"
compiler_package="ocaml-variants.${compiler_version}"
version_tag="${compiler_version/+/-}-ubuntu-24.04"
short_sha="${sha:0:12}"
snapshot_tag="opam-${short_sha}-${version_tag}"

cat <<EOF
opam_sha=$sha
opam_short_sha=$short_sha
compiler_version=$compiler_version
compiler_major_minor=$compiler_major_minor
compiler_package=$compiler_package
snapshot_tag=$snapshot_tag
EOF
