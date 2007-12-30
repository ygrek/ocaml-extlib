
RESULT:=extlib_test

EXTLIB_DIR:=../extlib-dev

TEST_OPTS=
ifdef USE_OCAMLFIND
TEST_OPTS=--use-ocamlfind
endif

all:
	ocamlc -g -o mktest str.cma unix.cma mktest.ml
	./mktest $(TEST_OPTS)

opt:
	ocamlc -o mktest str.cma unix.cma mktest.ml
	./mktest  $(TEST_OPTS) --opt

run:
	./$(RESULT)
