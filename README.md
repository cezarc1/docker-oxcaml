# Unofficial OxCaml containers

This repo is an external proof of concept for fast OxCaml onboarding with
standard container tooling.

The official [`oxcaml/playground`](https://github.com/oxcaml/playground)
appears stale from the outside: it has old open PRs, the prebuilt-image PR has
no public comments or reviews, and the public docs still warn that Codespaces
startup currently takes 30+ minutes. This repo accomplishes the same playground
task with prebuilt images, reproducible tags, smoke tests, and a Codespaces
configuration that starts from an already-built OxCaml toolchain.

This is not an official Jane Street or OxCaml project.

## Images

The workflow publishes two images:

| Image | Purpose |
| --- | --- |
| `ghcr.io/cezarc1/oxcaml-toolchain` | OxCaml switch plus editor/build tooling. |
| `ghcr.io/cezarc1/oxcaml-playground` | Toolchain image plus runnable playground examples. |

The same images are also pushed to Docker Hub when the repository has
`DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN` secrets:

| Image | Purpose |
| --- | --- |
| `docker.io/cezarc1/oxcaml-toolchain` | Docker Hub mirror of the toolchain image. |
| `docker.io/cezarc1/oxcaml-playground` | Docker Hub mirror of the playground image. |

Tags are based on the OxCaml opam repository snapshot:

```text
opam-<12-char-opam-repository-sha>-ubuntu-24.04
5.2.0-ox-ubuntu-24.04
latest
```

The immutable snapshot tag is the one to pin in downstream devcontainers. The
moving tags exist for quick experiments.

## Try It In Codespaces

Use GitHub's Codespaces creation UI and choose one of the devcontainer
configurations:

| Configuration | What it shows |
| --- | --- |
| `OxCaml Fast Playground (prebuilt)` | Uses `ghcr.io/cezarc1/oxcaml-playground:latest`; no opam install during startup. |
| `OxCaml Baseline (source-build)` | Builds the OxCaml switch during devcontainer creation, mirroring the slow path. |

GitHub Codespaces supports multiple devcontainer configurations, so the choice
appears at codespace creation time.

## Local Smoke Test

After an image exists:

```sh
scripts/smoke-image.sh ghcr.io/cezarc1/oxcaml-toolchain:latest toolchain
scripts/smoke-image.sh ghcr.io/cezarc1/oxcaml-playground:latest playground
```

Inside either image, use `with-oxcaml` to run commands in the OxCaml switch:

```sh
docker run --rm -it ghcr.io/cezarc1/oxcaml-toolchain:latest \
  with-oxcaml ocamlopt -version
```

## Measuring Startup

The script below uses the Dev Container CLI and writes logs under
`.measurements/`:

```sh
scripts/measure-devcontainer.sh fast-oxcaml
scripts/measure-devcontainer.sh baseline-source-build
```

Record the resulting timings here after the first published run:

| Path | Startup/build time | Notes |
| --- | ---: | --- |
| Official public docs | 20-30+ min | As documented by OxCaml's Get OxCaml page and playground README. |
| Baseline source-build config | Pending measurement | Builds the switch during container creation. |
| Fast prebuilt config | Pending measurement | Pulls a prebuilt image and builds only the tiny sample. |

## How Builds Track OxCaml

OxCaml does not currently publish clean GitHub releases, and the `oxcaml/oxcaml`
tags are not a stable image-versioning surface. The public installation path is
the OxCaml opam repository, so this repo keys image identity to
[`oxcaml/opam-repository`](https://github.com/oxcaml/opam-repository).

The build workflow:

1. Resolves the current `oxcaml/opam-repository` commit.
2. Checks whether `opam-<sha>-ubuntu-24.04` already exists.
3. Builds only when the snapshot tag is missing, or when manually forced.
4. Smoke-tests `ocamlopt`, `opam`, `dune`, `ocamllsp`, and the playground sample.
5. Pushes GHCR images and optionally Docker Hub mirrors.

## Upstream Adoption Path

The smallest upstream adoption path would be:

1. Publish an org-owned image such as `ghcr.io/oxcaml/playground:<snapshot>`.
2. Pin the digest in `oxcaml/playground/.devcontainer/devcontainer.json`.
3. Keep the Dockerfile and CI smoke test as the source of truth.
4. Update `oxcaml.org/get-oxcaml/` once the fast path is repeatably measured.

That would preserve the existing playground UX while removing the public
30-minute first-run tax.
