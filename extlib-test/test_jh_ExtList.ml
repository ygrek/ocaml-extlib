
open ExtList

exception Test_Exception

let check_empty_list_exn f = 
  try f (); false with List.Empty_list -> true

(** Random length list with [0;1;2;..n] contents. *)
let rnd_list () = 
  let len = Random.int 3 in 
  List.init len (fun n -> n)

let test_iteri () = 
  for i = 0 to 15 do
    List.iteri (fun i e -> assert (i = e)) (rnd_list ());
  done

let test_mapi () =
  for i = 0 to 15 do
    let rnd_list = rnd_list () in
    let lst = List.mapi (fun n e -> (e,"foo")) rnd_list in
    let lst' = 
      List.mapi (fun n (e,s) -> assert (s = "foo"); assert (n = e); n) lst in
    List.iteri (fun i e -> assert (i = e)) lst'
  done

let test_exceptions () = 
  assert (check_empty_list_exn (fun () -> List.hd []));
  assert (check_empty_list_exn (fun () -> List.first []));
  assert (check_empty_list_exn (fun () -> List.last []))

let test_find_exc () =
  let check_exn f = try f (); false with Test_Exception -> true | _ -> false in
  assert (check_exn (fun () -> (List.find_exc (fun _ -> true) Test_Exception [])));
  try 
    for i = 0 to 15 do
      let rnd_lst = rnd_list () in
      begin 
        match rnd_lst with
          [] -> ()
        | lst -> 
            let rnd_elem = Random.int (List.length lst) in
            assert (check_exn 
                      (fun () -> 
                         List.find_exc (fun e -> e = List.length lst) Test_Exception lst));
            assert (not (check_exn 
                           (fun () -> 
                              List.find_exc (fun e -> e = rnd_elem) Test_Exception lst)))
      end
    done
  with _ -> assert false

let test () = 
  Util.run_test ~test_name:"jh_ExtList.iteri" test_iteri;
  Util.run_test ~test_name:"jh_ExtList.mapi" test_mapi;
  Util.run_test ~test_name:"jh_ExtList.exceptions" test_exceptions;
  Util.run_test ~test_name:"jh_ExtList.find_exc" test_find_exc
    
