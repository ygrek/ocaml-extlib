
.NOTPARALLEL:
.SUFFIXES:
.PHONY: all opt run clean

TESTS := $(wildcard test_*.ml)

ifdef minimal
TESTS := $(filter-out test_Unzip.ml test_UChar.ml test_UTF8.ml, $(TESTS))
endif

all:
ifndef INSTALLED
	$(MAKE) -C ../src all minimal=$(minimal)
	ocamlfind ocamlc -linkall -linkpkg -package bytes -I ../src extLib.cma util.ml $(TESTS) runner.ml -o extlib_test
else
	ocamlfind ocamlc -linkall -linkpkg -package extlib util.ml $(TESTS) runner.ml -o extlib_test
endif

opt:
ifndef INSTALLED
	$(MAKE) -C ../src opt minimal=$(minimal)
	ocamlfind ocamlopt -linkall -linkpkg -package bytes -I ../src extLib.cmxa util.ml $(TESTS) runner.ml -o extlib_test
else
	ocamlfind ocamlopt -linkall -linkpkg -package extlib util.ml $(TESTS) runner.ml -o extlib_test
endif

run:
	./extlib_test

clean:
	rm -rf *.cm* *.o *.obj extlib_test
