(*
 * ExtLib Testing Suite
 * Copyright (C) 2013 ygrek
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

open ExtHashtbl

(* Issue 26: Hashtbl.map is broken in OCaml >= 4.00 *)
let test_map () =
  let h = Hashtbl.create 1 in
  Hashtbl.add h "test" 1;
  let h1 = Hashtbl.map (fun x -> x + 1) h in
  let find h k = try Some (Hashtbl.find h k) with Not_found -> None in
  assert (find h "test" = Some 1);
  assert (find h1 "test" = Some 2)

let () = 
  Util.register1 "ExtHashtbl" "map" test_map
