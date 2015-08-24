.SUFFIXES:
.PHONY: build clean test doc

build:
	$(MAKE) -C src build

doc:
	$(MAKE) -C src doc

test:
	$(MAKE) -C test all run
	$(MAKE) -C test opt run

clean:
	$(MAKE) -C src clean
	$(MAKE) -C test clean
