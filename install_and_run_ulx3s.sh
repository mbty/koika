#!/bin/bash

opam switch create 4.09 ocaml-base-compiler.4.09.0
opam install base=v0.13.1 coq=8.11.1 core=v0.13.0 dune=2.5.1 hashcons=1.3 parsexp=v0.13.0 stdio=v0.13.0 zarith=1.9.1
