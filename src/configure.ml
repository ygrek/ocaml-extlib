let show_bytes s =
    let (_:int) = Sys.command (Printf.sprintf "ocamlfind query -format %s bytes" (Filename.quote s)) in ()

let () =
  match Sys.argv with
  | [|_;"-cppo-args"|] ->
    print_endline (if Sys.ocaml_version >= "4.00.0" then "-D OCAML4 " else "");
    print_endline (if Sys.ocaml_version >= "4.02.0" then "-D OCAML4_02 " else "");
    print_endline (if Sys.ocaml_version >= "4.03.0" then "-D OCAML4_03 " else "");
    print_endline (if Sys.ocaml_version >= "4.04.0" then "-D OCAML4_04 " else "");
    print_endline (if Sys.ocaml_version >= "4.05.0" then "-D OCAML4_05 " else "");
    print_endline (if Sys.ocaml_version >= "4.06.0" then "-D OCAML4_06 " else "");
    print_endline (if Sys.ocaml_version >= "4.07.0" then "-D OCAML4_07 " else "");
    print_endline (if Sys.word_size = 32 then "-D WORD_SIZE_32 " else "");
    show_bytes "-D WITH_BYTES";
    exit 0
  | [|_;"-compile-args"|] ->
    if Sys.ocaml_version >= "4.00.0" then print_endline "-bin-annot";
    show_bytes "-package bytes";
    exit 0
  | _ -> failwith "not gonna happen"
