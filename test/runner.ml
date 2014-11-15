(** test runner *)

let () =
  let filter =
    match Array.to_list Sys.argv with
    | [] | [_] -> None
    | _::l -> Some (List.map String.lowercase l)
  in
  exit (if Util.run_all filter then 0 else 1)
