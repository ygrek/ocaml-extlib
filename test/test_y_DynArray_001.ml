(*
 * ExtLib Testing Suite
 * Copyright (C) 2004 Janne Hellsten
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

open DynArray

(* Issue 2: Error in DynArray exponential resizer *)
let test_dynarray1 () =
  let a = DynArray.create () in
  for i = 1 to 2817131 do
    DynArray.add a i
  done

let test_dynarray2 () =
  let a = DynArray.make 2817131 in
  for i = 1 to 2817131 do
    DynArray.add a i
  done
 
let test () = 
  Util.run_test ~test_name:"y_DynArray.dynarray1" test_dynarray1;
  Util.run_test ~test_name:"y_DynArray.dynarray2" test_dynarray2;
  ()

