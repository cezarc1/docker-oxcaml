# syntax=docker/dockerfile:1.7
FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

ARG OPAM_VERSION=2.3.0
ARG OXCAML_OPAM_REPOSITORY_URL=https://github.com/oxcaml/opam-repository.git
ARG OXCAML_OPAM_REPOSITORY_REF=main
ARG OXCAML_SWITCH=5.2.0+ox
ARG OXCAML_PACKAGES="dune ocamlformat merlin ocaml-lsp-server utop parallel core_unix"
ARG BUILD_DATE=unknown
ARG VCS_REF=unknown

LABEL org.opencontainers.image.title="Unofficial OxCaml toolchain" \
      org.opencontainers.image.description="Prebuilt, unofficial OxCaml opam switch for fast devcontainer startup" \
      org.opencontainers.image.source="https://github.com/cezarc1/docker-oxcaml" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.revision="${VCS_REF}" \
      dev.cezarc1.oxcaml.opam_repository="${OXCAML_OPAM_REPOSITORY_URL}" \
      dev.cezarc1.oxcaml.opam_repository_ref="${OXCAML_OPAM_REPOSITORY_REF}" \
      dev.cezarc1.oxcaml.switch="${OXCAML_SWITCH}" \
      dev.cezarc1.oxcaml.packages="${OXCAML_PACKAGES}" \
      dev.cezarc1.oxcaml.base_distro="ubuntu-24.04"

ENV DEBIAN_FRONTEND=noninteractive \
    OPAMYES=1 \
    OPAMCOLOR=never \
    OPAMROOT=/home/vscode/.opam \
    OXCAML_SWITCH=${OXCAML_SWITCH} \
    OXCAML_OPAM_REPOSITORY=/opt/oxcaml/opam-repository

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update && apt-get install -y --no-install-recommends \
      autoconf \
      build-essential \
      ca-certificates \
      curl \
      git \
      imagemagick \
      libffi-dev \
      libgmp-dev \
      libncurses-dev \
      libunwind-dev \
      m4 \
      patch \
      pkg-config \
      rsync \
      unzip \
      zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL \
      "https://github.com/ocaml/opam/releases/download/${OPAM_VERSION}/opam-${OPAM_VERSION}-x86_64-linux" \
      -o /usr/local/bin/opam \
    && chmod 0755 /usr/local/bin/opam

RUN mkdir -p /opt/oxcaml /home/vscode/.opam \
    && chown -R vscode:vscode /opt/oxcaml /home/vscode/.opam

USER vscode
WORKDIR /home/vscode

RUN git clone --filter=blob:none "${OXCAML_OPAM_REPOSITORY_URL}" "${OXCAML_OPAM_REPOSITORY}" \
    && cd "${OXCAML_OPAM_REPOSITORY}" \
    && git checkout "${OXCAML_OPAM_REPOSITORY_REF}" \
    && git rev-parse HEAD > /opt/oxcaml/opam-repository.rev

RUN opam init --disable-sandboxing --bare --yes \
    && opam switch create "${OXCAML_SWITCH}" --yes \
         --repos "ox=file://${OXCAML_OPAM_REPOSITORY},default" \
    && eval "$(opam env --switch="${OXCAML_SWITCH}" --set-switch)" \
    && opam install --yes ${OXCAML_PACKAGES} \
    && opam clean -a -c -s --logs

USER root

RUN printf '%s\n' \
      '#!/usr/bin/env bash' \
      'set -euo pipefail' \
      'eval "$(opam env --switch="${OXCAML_SWITCH:-5.2.0+ox}" --set-switch)"' \
      'exec "$@"' \
      > /usr/local/bin/with-oxcaml \
    && chmod 0755 /usr/local/bin/with-oxcaml \
    && printf '%s\n' \
      'if command -v opam >/dev/null 2>&1; then' \
      '  eval "$(opam env --switch="${OXCAML_SWITCH:-5.2.0+ox}" --set-switch 2>/dev/null)"' \
      'fi' \
      > /etc/profile.d/oxcaml.sh

USER vscode

CMD ["bash", "-l"]

