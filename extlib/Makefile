# Makefile contributed by Alain Frisch

VERSION = 1.5.4

# the list is topologically sorted
MODULES = \
 enum bitSet dynArray extArray extHashtbl extList extString global IO option \
 pMap std uChar uTF8 base64 unzip refList optParse dllist extLib

MODULES_MIN = $(filter-out base64 unzip uChar uTF8, $(MODULES))

OCAMLC = ocamlc -g
OCAMLOPT = ocamlopt -g

MLI = $(filter-out extLib.mli, $(MODULES:=.mli))
CMI = $(MODULES:=.cmi)
CMO = $(MODULES:=.cmo)
CMX = $(MODULES:=.cmx)

MLI_MIN = $(filter-out extLib.mli, $(MODULES_MIN:=.mli))
CMI_MIN = $(MODULES_MIN:=.cmi)
CMO_MIN = $(MODULES_MIN:=.cmo)
CMX_MIN = $(MODULES_MIN:=.cmx)

.SUFFIXES:
.PHONY: build all opt cmxs doc install uninstall clean release

build: all opt cmxs

all: extLib.cma extLib_min.cma
opt: extLib.cmxa extLib_min.cmxa
cmxs: extLib.cmxs extLib_min.cmxs

doc:
	$(OCAMLC) -c $(MLI)
	ocamldoc -sort -html -d doc/ $(MLI) extLib.ml

extLib.cma: $(CMO)
	$(OCAMLC) -a -o $@ $^
extLib_min.cma: $(CMO_MIN)
	$(OCAMLC) -a -o $@ $^
extLib.cmxa: $(CMX)
	$(OCAMLOPT) -a -o $@ $^
extLib_min.cmxa: $(CMX_MIN)
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
	ocamlfind install -patch-version $(VERSION) extlib_min min/META extLib_min.cma $(MLI_MIN) $(CMI_MIN) -optional extLib_min.cmxa $(CMX_MIN) extLib_min.cmxs extLib_min.a extLib_min.lib

uninstall:
	ocamlfind remove extlib
	ocamlfind remove extlib_min

clean:
	rm -f *.cmo *.cmx *.o *.obj *.cmi *.cma *.cmxa *.cmxs *.a *.lib doc/*.html extHashtbl.ml

release:
	svn export . extlib-$(VERSION)
	tar czf extlib-$(VERSION).tar.gz extlib-$(VERSION)
	gpg -a -b extlib-$(VERSION).tar.gz
	@echo make tag: svn copy https://ocaml-extlib.googlecode.com/svn/trunk https://ocaml-extlib.googlecode.com/svn/tags/extlib-$(VERSION)
