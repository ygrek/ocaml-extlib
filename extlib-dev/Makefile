all:
	ocamake -a -o ext-lib.cma *.ml *.mli

opt:
	ocamake -a -o ext-lib.cmxa -opt *.ml *.mli

clean:
	rm -rf dochtml ext-lib.odoc
	ocamake -a -o ext-lib.cma *.ml *.mli -clean
	ocamake -a -o ext-lib.cmxa -opt *.ml *.mli -clean

doc: all
	-mkdir dochtml
	ocamldoc -d dochtml -html *.mli
	cp odoc_style.css dochtml/style.css
	
doc-dump: all
	ocamldoc -dump ext-lib.odoc *.mli
