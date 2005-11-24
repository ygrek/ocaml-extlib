(*
 * ExtList - additional and modified functions for lists.
 * Copyright (C) 2005 Richard W.M. Jones (rich @ annexia.org)
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

module Array = struct

include Array

let rev_in_place xs =
  let n = length xs in
  let j = ref (n-1) in
  for i = 0 to n/2-1 do
    let c = xs.(i) in
    xs.(i) <- xs.(!j);
    xs.(!j) <- c;
    decr j
  done

let rev xs =
  let ys = Array.copy xs in
  rev_in_place ys;
  ys

let for_all p xs =
  let n = length xs in
  let rec loop i =
    if i = n then true
    else if p xs.(i) then loop (succ i)
    else false
  in
  loop 0

let exists p xs =
  let n = length xs in
  let rec loop i =
    if i = n then false
    else if p xs.(i) then true
    else loop (succ i)
  in
  loop 0

let mem a xs =
  let n = length xs in
  let rec loop i =
    if i = n then false
    else if a = xs.(i) then true
    else loop (succ i)
  in
  loop 0

let memq a xs =
  let n = length xs in
  let rec loop i =
    if i = n then false
    else if a == xs.(i) then true
    else loop (succ i)
  in
  loop 0

let findi p xs =
  let n = length xs in
  let rec loop i =
    if i = n then raise Not_found
    else if p xs.(i) then i
    else loop (succ i)
  in
  loop 0

let find p xs = xs.(findi p xs)

let filter p xs =
  let n = length xs in
  let inc = min n 1024 in
  (* Results list: a list of sub-arrays of size inc elements. *)
  let rs = ref [] in
  let rec loop i r =
    if i = n then r (* finished *)
    else (
      let r =
	if p xs.(i) then ( (* append xs.(i) to the result *)
	  if r < inc then (
	    let h = List.hd !rs in
	    h.(r) <- xs.(i);
	    succ r
	  ) else (
	    let h = Array.make inc xs.(i) in
	    rs := h :: !rs;
	    1
	  )
	)
	else
	  r in
      loop (succ i) r
    )
  in
  let r = loop 0 inc in
  let rs = !rs in
  (* Truncate final sub-array to the right size. *)
  let rs =
    if r = inc then rs else
      match rs with
      | [] -> []
      | h :: t ->
	  (Array.sub h 0 r) :: t in
  (* Concat into a single array. *)
  let rs = List.rev rs in
  concat rs

let find_all = filter

end
