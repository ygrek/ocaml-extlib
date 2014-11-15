(*
 * ExtLib Testing Suite
 * Copyright (C) 2004 Janne Hellsten
 * Copyright (C) 2008 Red Hat, Inc.
 * Copyright (C) 2010 ygrek
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version,
 * with the special exception on linking described in file LICENSE.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *)

(* Standard library list *)
module StdList = List

open ExtList

exception Test_Exception

let check_empty_list_exn f = 
  try f (); false with List.Empty_list -> true

(** Random length list with [0;1;2;..n] contents. *)
let rnd_list () = 
  let len = Random.int 3 in 
  List.init len Std.identity

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

let test_findi () =
  let check_fn f = try (let e,i = f () in e<>i) with Not_found -> true in
  try 
    for i = 0 to 15 do
      let rnd_lst = rnd_list () in
      begin 
        match rnd_lst with
          [] -> ()
        | lst -> 
            let rnd_elem = Random.int (List.length lst) in
            assert (check_fn 
                      (fun () -> 
                         List.findi (fun i e -> e = List.length lst) lst));
            assert (not (check_fn 
                           (fun () -> 
                              List.findi (fun i e -> e = rnd_elem) lst)))
      end
    done
  with _ -> assert false

let test_fold_right () = 
  let maxlen = 2000 in
  (* NOTE assuming we will not blow the stack with 2000 elements *)
  let lst = List.init maxlen Std.identity in
  let a = StdList.fold_right (fun e a -> e::a) lst [] in
  let b = List.fold_right (fun e a -> e::a) lst [] in
  assert (a = b)

let test_fold_right2 () = 
  let len = 2000 in
  let cnt = ref 0 in
  let lst = List.init len Std.identity in
  ignore (StdList.fold_right (fun e a -> incr cnt; e::a) lst []);
  let cnt_std = !cnt in
  cnt := 0;
  ignore (List.fold_right (fun e a -> incr cnt; e::a) lst []);
  assert (cnt_std = len);
  assert (!cnt = cnt_std)

let test_map () = 
  for i = 0 to 10 do
    let f = ( * ) 2 in
    let lst = rnd_list () in
    let a = StdList.map f lst in
    let b = List.map f lst in
    assert (a = b)
  done

let test_find_map () =
  let f = function "this", v -> Some v | _ -> None in
  (try
     let r = List.find_map f [ "a", 1; "b", 2; "this", 3; "d", 4 ] in
     assert (3 = r);
     let r = List.find_map f [ "this", 1; "b", 2; "c", 3; "d", 4 ] in
     assert (1 = r);
     let r = List.find_map f [ "a", 1; "b", 2; "c", 3; "this", 4 ] in
     assert (4 = r);
     let r = List.find_map f [ "this", 1; "b", 2; "c", 3; "this", 4 ] in
     assert (1 = r);
     let r = List.find_map f [ "a", 1; "b", 2; "this", 3; "this", 4 ] in
     assert (3 = r);
     let r = List.find_map f [ "this", 5 ] in
     assert (5 = r)
   with
     Not_found -> assert false
  );
  (try
     ignore (List.find_map f []); assert false
   with
     Not_found -> ()
  );
  (try
     ignore (List.find_map f [ "a", 1 ]); assert false
   with
     Not_found -> ()
  );
  (try
     ignore (List.find_map f [ "a", 1; "b", 2 ]); assert false
   with
     Not_found -> ()
  )

(* Issue 12: List.make not tail-recursive *)
let test_make () =
  let l = List.make 10_000_000 1 in
  assert (List.length l = 10_000_000)

let () =
  Util.register "ExtList" [
    "iteri", test_iteri;
    "mapi", test_mapi;
    "exceptions", test_exceptions;
    "find_exc", test_find_exc;
    "findi", test_findi;
    "fold_right", test_fold_right;
    "fold_right2", test_fold_right2;
    "map", test_map;
    "find_map", test_find_map;
    "make", test_make;
  ]
