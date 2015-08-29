
.SUFFIXES:
.PHONY: all opt run clean

all:
ifndef INSTALLED
	$(MAKE) -C ../src all
	ocamlfind ocamlc -linkall -linkpkg -package bytes -I ../src extLib.cma util.ml test_*.ml runner.ml -o extlib_test
else
	ocamlfind ocamlc -linkall -linkpkg -package extlib util.ml test_*.ml runner.ml -o extlib_test
endif

opt:
ifndef INSTALLED
	$(MAKE) -C ../src opt
	ocamlfind ocamlopt -linkall -linkpkg -package bytes -I ../src extLib.cmxa util.ml test_*.ml runner.ml -o extlib_test
else
	ocamlfind ocamlopt -linkall -linkpkg -package extlib util.ml test_*.ml runner.ml -o extlib_test
endif

run:
	./extlib_test

clean:
	rm -rf *.cm* *.o *.obj extlib_test
