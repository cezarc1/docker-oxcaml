# syntax=docker/dockerfile:1.7
ARG TOOLCHAIN_IMAGE=ghcr.io/cezarc1/oxcaml-toolchain:latest
FROM ${TOOLCHAIN_IMAGE}

ARG BUILD_DATE=unknown
ARG VCS_REF=unknown
ARG OXCAML_OPAM_REPOSITORY_REF=unknown

LABEL org.opencontainers.image.title="Unofficial OxCaml playground" \
      org.opencontainers.image.description="Fast Codespaces-ready OxCaml playground using a prebuilt toolchain image" \
      org.opencontainers.image.source="https://github.com/cezarc1/docker-oxcaml" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.revision="${VCS_REF}" \
      dev.cezarc1.oxcaml.opam_repository_ref="${OXCAML_OPAM_REPOSITORY_REF}" \
      dev.cezarc1.oxcaml.kind="playground"

USER root
RUN mkdir -p /opt/oxcaml-playground && chown -R vscode:vscode /opt/oxcaml-playground

USER vscode
WORKDIR /opt/oxcaml-playground
COPY --chown=vscode:vscode dune-project ./dune-project
COPY --chown=vscode:vscode examples ./examples
COPY --chown=vscode:vscode playground ./playground

RUN with-oxcaml dune build ./examples/hello

CMD ["bash", "-l"]
