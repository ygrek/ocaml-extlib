# Makefile contributed by Alain Frisch

VERSION = 1.6.1

# the list is topologically sorted
MODULES := \
 enum bitSet dynArray extArray extHashtbl extList extString global IO option \
 pMap std uChar uTF8 base64 unzip refList optParse dllist extLib

ifdef minimal
MODULES := $(filter-out unzip uChar uTF8, $(MODULES))
endif

OCAMLC = ocamlc -g
OCAMLOPT = ocamlopt -g

MLI = $(filter-out extLib.mli, $(MODULES:=.mli))
CMI = $(MODULES:=.cmi)
CMO = $(MODULES:=.cmo)
CMX = $(MODULES:=.cmx)

.SUFFIXES:
.PHONY: build all opt cmxs doc install uninstall clean release

build: all opt cmxs

all: extLib.cma
opt: extLib.cmxa
cmxs: extLib.cmxs

doc:
	$(OCAMLC) -c $(MLI)
	ocamldoc -sort -html -d doc/ $(MLI) extLib.ml

extLib.cma: $(CMO)
	$(OCAMLC) -a -o $@ $^
extLib.cmxa: $(CMX)
	$(OCAMLOPT) -a -o $@ $^
%.cmxs: %.cmxa
	$(OCAMLOPT) -shared -linkall $< -o $@
%.cmo: %.mli %.ml
	$(OCAMLC) -c $^
%.cmx: %.mli %.ml
	$(OCAMLOPT) -c $^
extLib.cmo: extLib.ml
	$(OCAMLC) -c $<
extLib.cmx: extLib.ml
	$(OCAMLOPT) -c $<
extHashtbl.ml: extHashtbl.mlpp
	camlp4of pr_o.cmo $(shell ocaml configure.ml) -impl $< -o $@

install:
	ocamlfind install -patch-version $(VERSION) extlib META extLib.cma $(MLI) $(CMI) -optional extLib.cmxa $(CMX) extLib.cmxs extLib.a extLib.lib

uninstall:
	ocamlfind remove extlib

clean:
	rm -f *.cmo *.cmx *.o *.obj *.cmi *.cma *.cmxa *.cmxs *.a *.lib doc/*.html extHashtbl.ml

release:
	svn export . extlib-$(VERSION)
	tar czf extlib-$(VERSION).tar.gz extlib-$(VERSION)
	gpg -a -b extlib-$(VERSION).tar.gz
	@echo make tag: svn copy https://ocaml-extlib.googlecode.com/svn/trunk https://ocaml-extlib.googlecode.com/svn/tags/extlib-$(VERSION)
