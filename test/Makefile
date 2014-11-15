
.SUFFIXES:
.PHONY: all opt run clean default

all:
ifndef USE_OCAMLFIND
	$(MAKE) -C ../src all
	ocamlc -I ../src extLib.cma util.ml test_*.ml runner.ml -o extlib_test
else
	ocamlfind ocamlc -linkpkg -package extlib util.ml test_*.ml -o extlib_test
endif

opt:
ifndef USE_OCAMLFIND
	$(MAKE) -C ../src opt
	ocamlopt -I ../src extLib.cmxa util.ml test_*.ml runner.ml -o extlib_test
else
	ocamlfind ocamlopt -linkpkg -package extlib util.ml test_*.ml -o extlib_test
endif

run:
	./extlib_test

clean:
	rm -rf *.cm* *.o *.obj extlib_test
