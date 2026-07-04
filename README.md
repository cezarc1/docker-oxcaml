# docker-oxcaml

Fast, unofficial OxCaml containers.

OxCaml's public playground still asks new users to wait 20-30+ minutes while a
Codespace builds the toolchain. This repo moves that wait into CI: pull a
prebuilt image, open a devcontainer, start hacking.

This is not an official Jane Street or OxCaml project.

## Try It

Open a Codespace. The default devcontainer is the fast path.

To compare with today's slow path, choose `OxCaml Baseline (source-build)`
from the devcontainer configuration dropdown.

Or run the playground image directly:

```sh
docker run --rm -it ghcr.io/cezarc1/oxcaml-playground:latest
```

## What Exists

- `ghcr.io/cezarc1/oxcaml-toolchain:latest`
- `ghcr.io/cezarc1/oxcaml-playground:latest`
- Immutable snapshot tag: `opam-d57b5d40e633-ubuntu-24.04`
- Docker Hub mirroring is wired, but waits on Docker Hub credentials.

The toolchain image includes OxCaml `5.2.0+ox`, `dune`, `ocamlformat`,
`merlin`, `ocaml-lsp-server`, `utop`, `parallel`, and `core_unix`.

## Proof

- First uncached toolchain image build: 60m 33s.
- Reusing the published toolchain, playground build plus smoke test: 4m 36s.
- CI smoke-tests `ocamlopt`, `opam`, `dune`, `ocamllsp`, and the example
  project.
- For the fastest Codespaces demo, enable a prebuild for `main` plus
  `.devcontainer/devcontainer.json` in repository Settings -> Codespaces. The
  example build runs in `updateContentCommand`, so GitHub can include it in the
  prebuild.
- Successful run:
  [`28720270392`](https://github.com/cezarc1/docker-oxcaml/actions/runs/28720270392).

## Why This Exists

The official [`oxcaml/playground`](https://github.com/oxcaml/playground)
appears stale from the outside: old open PRs, no public review on the
prebuilt-image PR, and public docs that still warn about long Codespaces
startup.

This repo is the smallest reproducible demonstration that prebuilt images solve
that onboarding problem with standard devcontainer tooling.
