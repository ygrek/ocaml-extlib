open Printf

let cppo_args define var =
  let version = Scanf.sscanf Sys.ocaml_version "%d.%d." (fun major minor -> major * 100 + minor) in
  var "OCAML" (string_of_int version);
  if Sys.word_size = 32 then define "WORD_SIZE_32";
  define "WITH_BYTES"

let () =
  match Sys.argv with
  | [|_;"-cppo-args"|] ->
    cppo_args (printf "-D %s ") (printf "-D '%s %s' ");
    exit 0
  | [|_;"-cppo-args-lines"|] ->
    let pr fmt = ksprintf print_endline fmt in
    cppo_args (fun x -> pr "-D"; pr "%s" x) (fun k v -> pr "-D"; pr "%s %s" k v);
    exit 0
  | _ -> failwith "not gonna happen"
