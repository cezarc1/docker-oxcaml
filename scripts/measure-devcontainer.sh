#!/usr/bin/env bash
set -euo pipefail

config="${1:?usage: measure-devcontainer.sh fast-oxcaml|baseline-source-build}"
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
out_dir="$root/.measurements"
mkdir -p "$out_dir"

case "$config" in
  fast-oxcaml|baseline-source-build) ;;
  *)
    echo "unknown devcontainer config: $config" >&2
    exit 2
    ;;
esac

log="$out_dir/${config}-$(date -u +%Y%m%dT%H%M%SZ).log"
start="$(date +%s)"

npx --yes @devcontainers/cli up \
  --workspace-folder "$root" \
  --config "$root/.devcontainer/$config/devcontainer.json" \
  2>&1 | tee "$log"

end="$(date +%s)"
elapsed="$((end - start))"

printf 'config=%s elapsed_seconds=%s log=%s\n' "$config" "$elapsed" "$log"

