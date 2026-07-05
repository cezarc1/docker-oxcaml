# docker-oxcaml

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/cezarc1/docker-oxcaml?quickstart=1)

Unofficial prebuilt OxCaml containers.

OxCaml's own [install page](https://oxcaml.org/get-oxcaml/) says that
initializing the public playground Codespace currently takes "30+ minutes." This
repo moves that toolchain build into CI so a devcontainer can start from an
already-built OxCaml image.

This is not an official Jane Street or OxCaml project.

## Try It

Click the badge, then run:

```sh
with-oxcaml dune build ./examples/hello
with-oxcaml dune exec ./examples/hello/bin/main.exe
```

Or pull the image locally:

```sh
docker run --rm -it ghcr.io/cezarc1/oxcaml-playground:latest
```

## Tags

Images are keyed to the latest public `ocaml-variants.*+ox` compiler in
`oxcaml/opam-repository`.

```text
5.2.0-ox-ubuntu-24.04                 exact compiler alias
5.2-ox-ubuntu-24.04                   latest smoke-tested 5.2.x build
latest                                latest smoke-tested OxCaml compiler
opam-d57b5d40e633-5.2.0-ox-ubuntu-24.04  exact opam snapshot provenance
```

Release aliases are mutable. Provenance tags carry the opam repository SHA.

## Evidence

- Uncached OxCaml toolchain image build: 60m 33s in
  [run 28718382229](https://github.com/cezarc1/docker-oxcaml/actions/runs/28718382229),
  which failed later on a playground packaging bug.
- Reusing the published toolchain, playground build plus smoke tests: 4m 36s in
  [run 28720270392](https://github.com/cezarc1/docker-oxcaml/actions/runs/28720270392).
- Codespaces startup time is not claimed yet; it should be measured after a
  repository prebuild is enabled.

## Context

The official [oxcaml/playground](https://github.com/oxcaml/playground) has a
[commented-out digest-pinned prebuilt image](https://github.com/oxcaml/playground/blob/main/.devcontainer/devcontainer.json),
and its public history shows a
[prebuilt-image switch reverted in June 2025](https://github.com/oxcaml/playground/commit/3b20c8ddd9251d32d9463f92574adcd80f6b301e).
A later [prebuilt-image PR](https://github.com/oxcaml/playground/pull/4)
remains open without public review.

This repo is a standalone demonstration of the release-image maintenance loop
around that idea: compiler-version tags, opam provenance tags, smoke tests
before alias promotion, and a pinned Codespaces devcontainer.
