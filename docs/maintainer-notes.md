# Maintainer Notes

This repo is a public proof of concept for prebuilt OxCaml onboarding. Keep the
README short; put operational details here.

## Codespaces Prebuild

GitHub stores Codespaces prebuilds as repository settings, not committed files.
Recommended setup:

- Branch: `main`
- Configuration: `.devcontainer/devcontainer.json`
- Trigger: `On configuration change`
- Retained versions: `1`
- Regions: restrict to 1-2 likely user regions to limit storage cost

The devcontainer intentionally pins a snapshot tag instead of `latest`. When a
new snapshot is accepted, update `.devcontainer/devcontainer.json` in the same
commit that documents the new image.

## Tag Policy

The build workflow discovers the highest `ocaml-variants.*+ox` package in
`oxcaml/opam-repository` and builds only that compiler version in v1.

Published tags per image:

- `opam-<12sha>-<version>-ox-ubuntu-24.04`: provenance tag for an exact opam
  repository snapshot.
- `<version>-ox-ubuntu-24.04`: exact compiler release alias.
- `<major>.<minor>-ox-ubuntu-24.04`: latest smoke-tested build in that compiler
  line.
- `latest`: latest smoke-tested build of the newest discovered OxCaml compiler.

Release aliases are mutable and refresh after smoke-tested rebuilds. Provenance
tags are immutable by convention; the workflow's `force` input may overwrite
them unless registry immutability rules prevent it.

## Known Limits

- No Codespaces startup-time number should be claimed until a fresh Codespace is
  measured after the repository prebuild is enabled.
- The first published images are `linux/amd64`; local Docker use on Apple
  Silicon will run under emulation until `arm64` images are added.
- Older compiler lines freeze once a newer OxCaml compiler appears; add a matrix
  only if users need maintained old-minor images.
- Docker Hub mirroring is wired in CI but requires `DOCKERHUB_USERNAME` and
  `DOCKERHUB_TOKEN` secrets.
- GHCR package visibility is currently a manual setup step.
- An official version should publish under an OxCaml-owned namespace such as
  `ghcr.io/oxcaml/...`.
