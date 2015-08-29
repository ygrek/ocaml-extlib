
VERSION:=$(shell git describe --always --long)
RELEASE:=1.7.0

ifndef VERSION
VERSION:=$(RELEASE)
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

NAME=extlib-$(RELEASE)

release:
	git tag -a -m $(RELEASE) $(RELEASE)
	# using github archive - it will have different checksum
	#git archive --prefix=$(NAME)/ $(RELEASE) | gzip > $(NAME).tar.gz
	# gpg -a -b $(NAME).tar.gz
