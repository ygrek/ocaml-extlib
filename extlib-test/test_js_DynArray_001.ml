(*
 * ExtLib Testing Suite (C) 2004 John Skaller 
   Licence LGPL + Ocaml exemption (Fix licence later)
 *)

open DynArray

exception Test_Exception

let test_triv () =
  let a = make 0 in
  let b = copy a in
  assert (length a == 0);
  assert (length b == 0);
  ()

let test () = 
  Util.run_test ~test_name:"js_DynArray.triv" test_triv

