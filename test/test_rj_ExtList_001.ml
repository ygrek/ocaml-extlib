(*
 * ExtLib Testing Suite
 * Copyright (C) 2008 Red Hat, Inc.
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

open ExtList

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

let test () = 
  Util.run_test ~test_name:"rj_ExtList_001.find_map" test_find_map
