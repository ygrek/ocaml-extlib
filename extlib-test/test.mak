
RESULT:=extlib_test
LIBS:=extLib
INCDIRS+=../extlib-dev

SOURCES:=\
	util.ml \
	test_jh_Base64.ml \
	test_Base64.ml \
	test_jh_BitSet.ml \
	test_BitSet.ml \
	test_jh_ExtList.ml \
	test_ExtList.ml \
	test_jh_ExtString.ml \
	test_ExtString.ml \
	test_main.ml \

all:debug-code
opt:native-code

run:
	./$(RESULT)

include OCamlMakefile
