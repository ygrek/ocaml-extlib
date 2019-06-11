module C = Configurator.V1

let _ =
  let flags = if Sys.word_size = 32 then ["-D"; "WORD_SIZE_32"] else [] in
  let version =
    Scanf.sscanf Sys.ocaml_version "%d.%d." (fun major minor ->
        (major * 100) + minor )
  in
  let flags = "-D" :: Printf.sprintf "OCAML %d" version :: flags in
  C.Flags.write_lines "cppo_flags" flags
