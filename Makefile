
VERSION=$(shell git describe --always --long)

ifndef VERSION
VERSION=1.7.0
endif

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

NAME=ocaml-extlib-$(VERSION)

release:
	git tag -a -m $(VERSION) $(VERSION)
	git archive --prefix=$(NAME)/ $(VERSION) | gzip > $(NAME).tar.gz
	gpg -a -b $(NAME).tar.gz
