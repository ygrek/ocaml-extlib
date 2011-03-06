(*
 * ExtLib Testing Suite
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

open ExtList

(* Issue 12: List.make not tail-recursive *)
let test_make () =
  let l = List.make 10_000_000 1 in
  assert (List.length l = 10_000_000)

let test () = 
  Util.run_test ~test_name:"y_ExtList_001.make" test_make;
  ()
