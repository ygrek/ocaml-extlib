# Makefile contributed by Alain Frisch

MODULES = \
 enum bitSet dbi dynArray extHashtbl extList extString global IO option \
 pMap refList std uChar uTF8 base64

# the list is topologically sorted

SRC = $(MODULES:=.mli) $(MODULES:=.ml) extLib.ml

all: 
	ocamlc -a -o extLib.cma $(SRC)
opt: 
	ocamlopt -a -o extLib.cmxa $(SRC)
doc:
	ocamlc -c $(MODULES:=.mli)
	mkdir -p doc/
	ocamldoc -sort -html -d doc/ $(MODULES:=.mli)
	cp odoc_style.css doc/style.css

install:
	cp META.txt META
	ocamlfind install extlib META *.cmi *.cma $(wildcard *.cmxa) $(wildcard *.a)

uninstall:
	ocamlfind remove extlib

clean:
	rm -f *.cmo *.cmx *.o *.cmi *.cma *.cmxa *.a
	rm -Rf doc
