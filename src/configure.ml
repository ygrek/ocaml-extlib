let () =
  print_endline (if Sys.ocaml_version >= "4.00.0" then "-D OCAML4 " else "");
  print_endline (if Sys.ocaml_version >= "4.02.0" then "-D OCAML4_02 " else "");
  let (_:int) = Sys.command "ocamlfind query -format \"-D WITH_BYTES\" bytes" in ();
  exit 0
