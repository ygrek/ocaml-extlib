# Makefile contributed by Alain Frisch

VERSION = 1.5.4

MODULES = \
 enum bitSet dynArray extArray extHashtbl extList extString global IO option \
 pMap std uChar uTF8 base64 unzip refList optParse dllist

# the list is topologically sorted

MLI = $(MODULES:=.mli)
CMI = $(MODULES:=.cmi)
CMX = $(MODULES:=.cmx)
SRC = $(MLI) $(MODULES:=.ml) extLib.ml

.PHONY: all opt cmxs doc install uninstall clean release

all: 
	ocamlc -a -o extLib.cma $(SRC)
opt: 
	ocamlopt -a -o extLib.cmxa $(SRC)
cmxs: opt
	ocamlopt -shared -linkall extLib.cmxa -o extLib.cmxs
doc:
	ocamlc -c $(MLI)
	ocamldoc -sort -html -d doc/ $(MLI)

install:
	ocamlfind install -patch-version $(VERSION) extlib META extLib.cma extLib.cmi $(MLI) $(CMI) -optional extLib.cmxa $(CMX) extLib.cmxs extLib.a extLib.lib

uninstall:
	ocamlfind remove extlib

clean:
	rm -f *.cmo *.cmx *.o *.obj *.cmi *.cma *.cmxa *.cmxs *.a *.lib doc/*.html

release:
	svn export . extlib-$(VERSION)
	tar czf extlib-$(VERSION).tar.gz extlib-$(VERSION)
	gpg -a -b extlib-$(VERSION).tar.gz
	@echo make tag: svn copy https://ocaml-extlib.googlecode.com/svn/trunk https://ocaml-extlib.googlecode.com/svn/tags/extlib-$(VERSION)
