#!/bin/sh

gcc zlib-test.c -lz -o zlib-test

compression_levels="1 2 3 4 5 6 7 8 9"
strings="a b c aa aaa aaaa foobar 012345678 00000000 aaaaaaaaaa -------------------------aaaaaaaaa------------------"

for s in $strings; do
for cl in $compression_levels; do
    compressed=`./zlib-test $cl "$s"`
    echo "$s, $compressed"
done;
done
