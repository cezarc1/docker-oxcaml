#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
resolver="${root}/scripts/resolve-upstream.sh"
tmp_root="$(mktemp -d)"

cleanup() {
  rm -rf "$tmp_root"
}
trap cleanup EXIT

make_repo() {
  local name="$1"
  shift
  local repo="${tmp_root}/${name}"
  mkdir -p "${repo}/packages/ocaml-variants"
  git -C "$repo" init -q
  git -C "$repo" config user.email test@example.invalid
  git -C "$repo" config user.name "Resolver Test"
  git -C "$repo" config uploadpack.allowFilter true
  git -C "$repo" config uploadpack.allowReachableSHA1InWant true

  local version
  for version in "$@"; do
    mkdir -p "${repo}/packages/ocaml-variants/ocaml-variants.${version}"
    printf 'opam-version: "2.0"\n' > "${repo}/packages/ocaml-variants/ocaml-variants.${version}/opam"
  done

  git -C "$repo" add .
  git -C "$repo" commit -q -m "add fake OxCaml variants"
  git -C "$repo" branch -M main
  printf '%s\n' "$repo"
}

run_resolver() {
  local repo="$1"
  shift
  OXCAML_OPAM_REPOSITORY_URL="file://${repo}" "$@" "$resolver" main
}

get_value() {
  local output="$1"
  local key="$2"
  printf '%s\n' "$output" | awk -F= -v key="$key" '$1 == key { print $2 }'
}

assert_value() {
  local output="$1"
  local key="$2"
  local expected="$3"
  local actual
  actual="$(get_value "$output" "$key")"
  if [ "$actual" != "$expected" ]; then
    echo "expected ${key}=${expected}, got ${actual:-<missing>}" >&2
    echo "$output" >&2
    exit 1
  fi
}

assert_snapshot_shape() {
  local output="$1"
  local version_tag="$2"
  local snapshot
  snapshot="$(get_value "$output" snapshot_tag)"
  if [[ ! "$snapshot" =~ ^opam-[0-9a-f]{12}-${version_tag}$ ]]; then
    echo "unexpected snapshot_tag: ${snapshot}" >&2
    echo "$output" >&2
    exit 1
  fi
}

repo="$(make_repo one-version 5.2.0+ox)"
output="$(run_resolver "$repo" env)"
assert_value "$output" compiler_version "5.2.0+ox"
assert_value "$output" compiler_major_minor "5.2"
assert_value "$output" compiler_package "ocaml-variants.5.2.0+ox"
assert_snapshot_shape "$output" "5.2.0-ox-ubuntu-24.04"

repo="$(make_repo newer-minor 5.2.0+ox 5.3.0+ox)"
output="$(run_resolver "$repo" env)"
assert_value "$output" compiler_version "5.3.0+ox"
assert_value "$output" compiler_major_minor "5.3"

repo="$(make_repo newer-patch 5.2.0+ox 5.2.1+ox)"
output="$(run_resolver "$repo" env)"
assert_value "$output" compiler_version "5.2.1+ox"
assert_value "$output" compiler_major_minor "5.2"

repo="$(make_repo override 5.2.0+ox 5.3.0+ox)"
output="$(run_resolver "$repo" env OXCAML_SWITCH=5.2.0+ox)"
assert_value "$output" compiler_version "5.2.0+ox"
assert_value "$output" compiler_major_minor "5.2"

repo="$(make_repo missing-override 5.2.0+ox)"
if run_resolver "$repo" env OXCAML_SWITCH=5.3.0+ox >"${tmp_root}/resolve-missing.out" 2>"${tmp_root}/resolve-missing.err"; then
  echo "missing override unexpectedly succeeded" >&2
  exit 1
fi

repo="$(make_repo weird-variant 5.2.0+ox 5.2.0+ox+weird)"
output="$(run_resolver "$repo" env)"
assert_value "$output" compiler_version "5.2.0+ox"

echo "resolver tests passed"
