open Printf

let cppo_args define var =
  let version = Scanf.sscanf Sys.ocaml_version "%d.%d.%d" (fun major minor patch -> sprintf "%d.%d.%d" major minor patch) in
  var "OCAML" version;
  if Sys.word_size = 64 then define "WORD_SIZE_64_true"

let () =
  match Sys.argv with
  | [|_;"-cppo-args"|] ->
    cppo_args (printf "-D %s ") (printf "-V '%s:%s' ");
    exit 0
  | [|_;"-compile-args"|] ->
    exit 0
  | _ -> failwith "not gonna happen"
