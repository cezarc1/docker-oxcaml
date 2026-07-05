#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
config="${root}/.devcontainer/devcontainer.json"

npx --yes @devcontainers/cli up \
  --workspace-folder "$root" \
  --config "$config"

npx --yes @devcontainers/cli exec \
  --workspace-folder "$root" \
  --config "$config" \
  with-oxcaml ocamlopt -version

npx --yes @devcontainers/cli exec \
  --workspace-folder "$root" \
  --config "$config" \
  with-oxcaml dune build ./examples/hello

npx --yes @devcontainers/cli exec \
  --workspace-folder "$root" \
  --config "$config" \
  with-oxcaml dune exec ./examples/hello/bin/main.exe
