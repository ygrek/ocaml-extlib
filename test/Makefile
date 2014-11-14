
all:
ifndef USE_OCAMLFIND
	cd ../src && make all
endif
	make -f test.mak all

opt:
ifndef USE_OCAMLFIND
	cd ../src && make opt
endif
	make -f test.mak opt

run:
	make -f test.mak run

