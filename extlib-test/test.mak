
RESULT:=extlib_test

EXTLIB_DIR:=../extlib-dev

all:
	ocamlc -o mktest str.cma unix.cma mktest.ml
	./mktest

run:
	./$(RESULT)
