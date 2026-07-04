#!/usr/bin/env bash
set -euo pipefail

image="${1:?usage: smoke-image.sh IMAGE [toolchain|playground]}"
kind="${2:-toolchain}"

docker run --rm "$image" bash -lc '
  set -euo pipefail
  with-oxcaml ocamlopt -version
  with-oxcaml opam switch show
  with-oxcaml dune --version
  with-oxcaml ocamllsp --version
  test -f /opt/oxcaml/opam-repository.rev
'

if [ "$kind" = "playground" ]; then
  docker run --rm "$image" bash -lc '
    set -euo pipefail
    cd /opt/oxcaml-playground
    with-oxcaml dune build ./examples/hello
    with-oxcaml dune exec ./examples/hello/bin/main.exe
  '
fi

