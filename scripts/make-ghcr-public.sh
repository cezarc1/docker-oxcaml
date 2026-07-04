#!/usr/bin/env bash
set -euo pipefail

owner="${GITHUB_REPOSITORY_OWNER:-cezarc1}"

if [ "$owner" != "cezarc1" ]; then
  echo "skipping GHCR visibility update for non-user owner: $owner"
  exit 0
fi

for package in oxcaml-toolchain oxcaml-playground; do
  gh api \
    --method PATCH \
    "/user/packages/container/${package}/visibility" \
    -f visibility=public \
    >/dev/null || true
done

