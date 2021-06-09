=========================================================
Kôika: A Core Language for Rule-Based Hardware Design
=========================================================

Dépendances à installer via le gestionnaire de paquets :
- g++ (via gcc) ;
- opam ;
- yosys.

Puis :
```sh
opam init
opam switch create 4.09 ocaml-base-compiler.4.09.0
opam install base=v0.13.1 coq=8.11.1 core=v0.13.0 dune=2.5.1 hashcons=1.3 parsexp=v0.13.0 stdio=v0.13.0 zarith=1.9.1
```

Les informations suivant cette ligne sont extraites du README original et
concernent le processus d'installation. A priori, elles ne devraient pas être
nécessaires.

Getting started
===============

Installing dependencies and building from source
------------------------------------------------

* OCaml 4.07 through 4.09, `opam <https://opam.ocaml.org/doc/Install.html>`_ 2.0 or later, GNU make.

* Coq 8.11 through 8.13::

    opam install coq=8.12.2

* Dune 2.5 or later::

    opam upgrade dune

* Some OCaml packages::

    opam install base core stdio parsexp hashcons zarith

* To run the tests of our RISCV core, a `RISCV compilation toolchain <https://github.com/xpack-dev-tools/riscv-none-embed-gcc-xpack/releases/>`_.

* To run C++ simulations: a recent C++ compiler (clang or gcc), ``libboost-dev``, and optionally ``clang-format``.

You can compile the full distribution, including examples, tests, and proofs by running ``make`` in the top-level directory of this repo.  Generated files are placed in ``_build``, ``examples/_objects/``,  ``tests/_objects/``, and  ``examples/rv/_objects/``.

Each directory in ``_objects`` contains `a Makefile <makefile_>`_ to ease further experimentation (including RTL simulation, profiling, trace generation, etc.).

.. opam show -f name,version coq dune base core stdio parsexp hashcons zarith | sed 's/name *//' | tr '\n' ' ' | sed 's/ *version */=/g' | xclip

For reproducibility, here is one set of versions known to work:

- OCaml 4.09 with ``opam install base=v0.13.1 coq=8.11.1 core=v0.13.0 dune=2.5.1 hashcons=1.3 parsexp=v0.13.0 stdio=v0.13.0 zarith=1.9.1``

FPGA
====

The Makefiles that ``cuttlec`` generates include targets for generating ECP5 and ICE40 bitstreams.  The default ECP5 target is set up for the `ULX3S-85k <https://www.crowdsupply.com/radiona/ulx3s>`__ FPGA.  The default ICE40 target is set up for the `TinyFPGA BX <https://www.crowdsupply.com/tinyfpga/tinyfpga-ax-bx>`__.  Both are reasonably affordable FPGAs (but note that right now the RV32i code does not fit on the TinyFPGA BX).

To run the RISCV5 core on the ULX3S on Ubuntu 20:

- Download a prebuilt ECP5 toolchain from `<https://github.com/YosysHQ/fpga-toolchain/releases>`__.
- Make sure that the trivial example at https://github.com/ulx3s/blink works.
- Run ``make core`` in ``examples/rv`` to compile the RISCV core (other designs should work too, but you'll need to create a custom wrapper in Verilog to map inputs and outputs to your FPGAs pins.
- Run ``make top_ulx3s.bit`` in ``examples/rv/_objects/rv32i.v/`` to generate a bitstream.  You can prefix this command with ``MEM_NAME=integ/morse`` (or any other test program) to load a different memory image into the bitstream.
- Run ``fujprog top_ulx3s.bit`` to flash the FPGA.
- To see the output of ``putchar()``, use a TTY application like ``tio``: ``tio /dev/ttyUSB0`` (the default baud rate is 115200).
