(lang dune 3.16)
(name extlib)

(generate_opam_files true)
(formatting (enabled_for dune))

(source (github ygrek/ocaml-extlib))
(documentation "https://ygrek.org/p/extlib/doc/")
(maintainers "ygrek@autistici.org")
(license "LGPL-2.1-only WITH OCaml-LGPL-linking-exception")

(package
 (name extlib)
 (synopsis "A complete yet small extension for OCaml standard library")
 (description
 "The purpose of this library is to add new functions to OCaml standard library
modules, to modify some functions in order to get better performances or
safety (tail-recursive) and also to provide new modules which should be useful
for day to day programming.

Current goal is to maintain compatibility, new software is encouraged to not use extlib since stdlib
is now seeing many additions and improvements which make many parts of extlib obsolete.
For tail-recursion safety consider using other libraries e.g. containers.
")
 (authors
  "Nicolas Cannasse"
   "Brian Hurt"
   "Yamagata Yoriyuki"
   "Markus Mottl"
   "Jesse Guardiani"
   "John Skaller"
   "Bardur Arantsson"
   "Janne Hellsten"
   "Richard W.M. Jones"
   "ygrek"
   "Gabriel Scherer"
   "Pietro Abate")
  (depends
   (ocaml (>= "4.02"))
   (cppo (and :build (>= "1.0.1")))))
  
