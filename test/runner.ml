(** test runner *)

let () =
  let filter =
    match Array.to_list Sys.argv with
    | [] | [_] -> None
    | _::l -> Some (List.map ExtString.String.lowercase l)
  in
  let tests = [
    Test_BitSet.register;
    Test_Dllist.register;
    Test_DynArray.register;
    Test_ExtArray.register;
    Test_ExtHashtbl.register;
    Test_ExtList.register;
    Test_ExtString.register;
    Test_IO.register;
  ]
  in
  List.iter (fun register -> register ()) tests;

  exit (if Util.run_all filter then 0 else 1)
