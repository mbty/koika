OBJ_DIR := _obj
BUILD_DIR := _build/default
COQ_BUILD_DIR := ${BUILD_DIR}/coq
OCAML_BUILD_DIR := ${BUILD_DIR}/ocaml

V ?=
verbose := $(if $(V),,@)

default: all

#######
# Coq #
#######

coq:
	@printf "\n== Building Coq library ==\n"
	dune build @@coq/all

coq-all:
	@printf "\n== Building Coq library and proofs ==\n"
	dune build @coq/all

CHECKED_MODULES ?= OneRuleAtATime CompilerCorrectness/Correctness
checked_paths := $(patsubst %,$(COQ_BUILD_DIR)/%.vo,$(CHECKED_MODULES))

coq-check: coq-all
	coqchk --output-context -R $(COQ_BUILD_DIR) Koika $(checked_paths)

fpga:
	cd examples/rv/_objects/rv32i.v/ && make MEM_NAME=unit/led top_ulx3s.bit &&\
	./fujprog top_ulx3s.bit

.PHONY: coq coq-all coq-check

#########
# OCaml #
#########

ocaml:
	@printf "\n== Building OCaml library and executables ==\n"
	dune build ocaml/cuttlec.exe @install

.PHONY: ocaml

############
# Examples #
############

# The setup below generates one Makefile rule per target.  It uses canned rules
# and eval because patterns like ‘%1/_objects/%2.v/: %1/%2.v’ aren't supported.
# https://www.gnu.org/software/make/manual/html_node/Canned-Recipes.html
# https://www.gnu.org/software/make/manual/html_node/Eval-Function.html

target_directory = $(dir $(1))_objects/$(notdir $(1))
target_directories = $(foreach fname,$(1),$(call target_directory,$(fname)))

define cuttlec_recipe_prelude =
	@printf "\n-- Compiling %s --\n" "$<"
endef

# Execute follow-ups if any
define cuttlec_recipe_coda =
	$(verbose)if [ -d $<.etc ]; then cp -rf $<.etc/. -t "$@"; fi
	$(verbose)if [ -d $(dir $<)etc ]; then cp -rf $(dir $<)etc/. -t "$@"; fi
	$(verbose)if [ -f "$@/Makefile" ]; then $(MAKE) -C "$@"; fi
endef

# Compile a .lv file
define cuttlec_lv_recipe_body =
	dune exec -- cuttlec "$<" \
		-T all -o "$@" $(if $(findstring .1.,$<),--expect-errors 2> "$@stderr")
endef

# Compile a .v file
define cuttlec_v_recipe_body =
	dune build "$@/$(notdir $(<:.v=.ml))"
	dune exec -- cuttlec "${BUILD_DIR}/$@/$(notdir $(<:.v=.ml))" -T all -o "$@"
endef

define cuttlec_lv_template =
$(eval dirpath := $(call target_directory,$(1)))
$(dirpath) $(dirpath)/: $(1) ocaml | configure
	$(value cuttlec_recipe_prelude)
	$(value cuttlec_lv_recipe_body)
	$(value cuttlec_recipe_coda)
endef

define cuttlec_v_template =
$(eval dirpath := $(call target_directory,$(1)))
$(dirpath) $(dirpath)/: $(1) ocaml | configure
	$(value cuttlec_recipe_prelude)
	$(value cuttlec_v_recipe_body)
	$(value cuttlec_recipe_coda)
endef

EXAMPLES := examples/rv/rv32i.v examples/rv/rv32e.v

configure:
	etc/configure $(filter %.v, ${EXAMPLES})

$(foreach fname,$(filter %.lv, $(EXAMPLES)),\
	$(eval $(call cuttlec_lv_template,$(fname))))
$(foreach fname,$(filter %.v, $(EXAMPLES)),\
	$(eval $(call cuttlec_v_template,$(fname))))

examples: $(call target_directories,$(EXAMPLES));
clean-examples:
	find examples/ -type d \( -name _objects -or -name _build \) -exec rm -rf {} +
	rm -rf ${BUILD_DIR}/examples

.PHONY: configure examples clean-examples

#################
# Whole project #
#################

package:
	etc/package.sh

dune-all: coq ocaml
	@printf "\n== Completing full build ==\n"
	dune build @all

all: coq ocaml examples fpga;

clean: clean-examples
	dune clean
	rm -f koika-*.tar.gz

.PHONY: package dune-all all clean

.SUFFIXES:

# Running two copies of dune in parallel isn't safe, and dune is already
# handling most of the parallelism for us
.NOTPARALLEL:

# Disable built-in rules
MAKEFLAGS += --no-builtin-rules
.SUFFIXES:
