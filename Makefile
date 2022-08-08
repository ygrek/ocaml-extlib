
VERSION:=$(shell git --git-dir=.git describe --always --long)
RELEASE:=1.7.9

ifndef VERSION
VERSION:=$(RELEASE)
endif

.NOTPARALLEL:
.SUFFIXES:

.PHONY: build
build:
	dune build

.PHONY: install
install:
	dune install

.PHONY: doc
doc:
	dune build @doc

.PHONY: test
test:
	dune runtest

.PHONY: clean
clean:
	dune clean

NAME=extlib-$(RELEASE)

.PHONY: release
release:
	git tag -a -m $(RELEASE) $(RELEASE)
	git archive --prefix=$(NAME)/ $(RELEASE) | gzip > $(NAME).tar.gz
	gpg -a -b $(NAME).tar.gz -o $(NAME).tar.gz.asc

.PHONY: sw_test_all sw_deps_all

define gen_sw =
sw_test_all:: sw_test_$(1)
sw_deps_all:: sw_deps_$(1)

.PHONY: sw_deps_$(1)
sw_deps_$(1):
	opam install --switch=$(1) -y --deps-only .

.PHONY: sw_test_$(1)
sw_test_$(1):
	-opam exec --switch=$(1) -- make clean build test >/dev/null 2>/dev/null
# expected to fail < 4.03.0
ifneq "$(1)" "4.02.3"
	-opam exec --switch=$(1) -- ocaml check_stdlib.ml
endif
endef

$(foreach version,\
	4.02.3\
	4.03.0\
	4.04.2\
	4.05.0\
	4.06.1\
	4.07.1\
	4.08.0\
	4.09.1\
	4.10.2\
	4.11.1\
	4.12.0\
	4.13.1\
	4.14.0\
	5.0.0~alpha1\
,$(eval $(call gen_sw,$(version))))
