
RESULT:=extlib_test

SOURCES:=\
	util.ml \
	test_jh_Base64.ml \
	test_Base64.ml \
	test_jh_BitSet.ml \
	test_BitSet.ml \
	test_jh_Dllist.ml \
	test_Dllist.ml \
	test_jh_ExtList.ml \
	test_ExtList.ml \
	test_jh_ExtString.ml \
	test_ExtString.ml \
	test_js_DynArray_001.ml \
	test_DynArray.ml \
	test_main.ml \

EXTLIB_DIR:=../extlib-dev

all:
	ocamlc -I $(EXTLIB_DIR) -g extLib.cma $(SOURCES) -o $(RESULT)

opt:
	ocamlopt -I $(EXTLIB_DIR) extLib.cmxa $(SOURCES) -o $(RESULT)

run:
	./$(RESULT)
