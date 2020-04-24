
VERSION:=$(shell git --git-dir=.git describe --always --long)
RELEASE:=1.7.7

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
	gpg -a -b $(NAME).tar.gz

.PHONY: test_all

define gen_test =
test_all:: test_$(1)

.PHONY: test_$(1)
test_$(1):
	opam exec --switch=$(1) -- make clean build test > /dev/null
# expected to fail < 4.03.0
#	opam exec --switch=$(1) -- ocaml test/std.ml
endef

$(foreach version,3.12.1 4.00.1 4.01.0 4.02.3 4.03.0 4.04.2 4.05.0 4.06.0 4.06.1 4.07.1 4.08.0 4.09.0 4.10.0,$(eval $(call gen_test,$(version))))
