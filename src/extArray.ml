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

#if OCAML < 408
type 'a t = 'a array
#endif

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

#if OCAML < 403
let for_all p xs =
  let n = length xs in
  let rec loop i =
    if i = n then true
    else if p xs.(i) then loop (succ i)
    else false
  in
  loop 0

exception Exists

let exists p xs =
  try
    for i = 0 to Array.length xs - 1 do
      if p xs.(i) then raise Exists
    done; false
  with Exists -> true

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
#endif

let findi p xs =
  let n = length xs in
  let rec loop i =
    if i = n then raise Not_found
    else if p xs.(i) then i
    else loop (succ i)
  in
  loop 0

let find p xs = xs.(findi p xs)

(* Use of BitSet suggested by Brian Hurt. *)
let filter p xs =
  let n = length xs in
  (* Use a bitset to store which elements will be in the final array. *)
  let bs = BitSet.create n in
  for i = 0 to n-1 do
    if p xs.(i) then BitSet.set bs i
  done;
  (* Allocate the final array and copy elements into it. *)
  let n' = BitSet.count bs in
  let j = ref 0 in
  let xs' = init n'
    (fun _ ->
       (* Find the next set bit in the BitSet. *)
       while not (BitSet.is_set bs !j) do incr j done;
       let r = xs.(!j) in
       incr j;
       r) in
  xs'

let find_all = filter

#if OCAML < 411

let for_all2 p l1 l2 =
  let n1 = length l1
  and n2 = length l2 in
  if n1 <> n2 then invalid_arg "Array.for_all2"
  else let rec loop i =
    if i = n1 then true
    else if p (unsafe_get l1 i) (unsafe_get l2 i) then loop (succ i)
    else false in
  loop 0

let exists2 p l1 l2 =
  let n1 = length l1
  and n2 = length l2 in
  if n1 <> n2 then invalid_arg "Array.exists2"
  else let rec loop i =
    if i = n1 then false
    else if p (unsafe_get l1 i) (unsafe_get l2 i) then true
    else loop (succ i) in
  loop 0

#endif

let partition p xs =
  let n = length xs in
  (* Use a bitset to store which elements will be in which final array. *)
  let bs = BitSet.create n in
  for i = 0 to n-1 do
    if p xs.(i) then BitSet.set bs i
  done;
  (* Allocate the final arrays and copy elements into them. *)
  let n1 = BitSet.count bs in
  let n2 = n - n1 in
  let j = ref 0 in
  let xs1 = init n1
    (fun _ ->
       (* Find the next set bit in the BitSet. *)
       while not (BitSet.is_set bs !j) do incr j done;
       let r = xs.(!j) in
       incr j;
       r) in
  let j = ref 0 in
  let xs2 = init n2
    (fun _ ->
       (* Find the next clear bit in the BitSet. *)
       while BitSet.is_set bs !j do incr j done;
       let r = xs.(!j) in
       incr j;
       r) in
  xs1, xs2

let enum xs =
  let rec make start xs =
    let n = length xs in
    Enum.make
      ~next:(fun () ->
         if !start < n then (
     let r = xs.(!start) in
     incr start;
     r
         ) else
     raise Enum.No_more_elements)
      ~count:(fun () ->
    n - !start)
      ~clone:(fun () ->
    let xs' = Array.sub xs !start (n - !start) in
    make (ref 0) xs')
  in
  make (ref 0) xs

let of_enum e =
  let n = Enum.count e in
  (* This assumes, reasonably, that init traverses the array in order. *)
  Array.init n
    (fun i ->
       match Enum.get e with
       | Some x -> x
       | None -> assert false)

#if OCAML < 403
let iter2 f a1 a2 =
     if Array.length a1 <> Array.length a2
     then raise (Invalid_argument "Array.iter2");
     for i = 0 to Array.length a1 - 1 do
       f a1.(i) a2.(i);
     done

let map2 f a1 a2 =
     if Array.length a1 <> Array.length a2
     then raise (Invalid_argument "Array.map2");
     Array.init (Array.length a1) (fun i -> f a1.(i) a2.(i))
#endif

#if OCAML >= 500
let make_float = create_float
let create_matrix = make_matrix
external create : int -> 'a -> 'a array = "caml_make_vect"
#else
#if OCAML >= 403
#else
#if OCAML >= 402
let create_float = make_float
#else
let make_float n = make n 0.
let create_float = make_float
#endif
#endif
#endif

end
