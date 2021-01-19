
VERSION:=$(shell git --git-dir=.git describe --always --long)
RELEASE:=1.7.8

ifndef VERSION
VERSION:=$(RELEASE)
endif

.NOTPARALLEL:
.SUFFIXES:
.PHONY: build clean test doc release install

build:
	$(MAKE) -C src build

install:
	$(MAKE) -C src VERSION=$(VERSION) install

doc:
	$(MAKE) -C src doc

test:
	$(MAKE) -C test all run
	$(MAKE) -C test opt run

clean:
	$(MAKE) -C src clean
	$(MAKE) -C test clean

NAME=extlib-$(RELEASE)

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
ifneq "$(1)" "3.12.1"
ifneq "$(1)" "4.00.1"
ifneq "$(1)" "4.01.0"
ifneq "$(1)" "4.02.3"
	-opam exec --switch=$(1) -- ocaml test/std.ml
endif
endif
endif
endif
endef

$(foreach version,\
	3.12.1\
	4.00.1\
	4.01.0\
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
	4.12.0~beta1\
,$(eval $(call gen_sw,$(version))))
