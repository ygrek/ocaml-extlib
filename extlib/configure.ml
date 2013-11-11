let () = print_endline (if Sys.ocaml_version >= "4.00.0" then "-D OCAML4" else ""); exit 0
