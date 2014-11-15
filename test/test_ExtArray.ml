(*
 * ExtLib Testing Suite
 * Copyright (C) 2005 Richard W.M. Jones
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

(* Standard library array. *)
module StdArray = Array

open ExtArray

let test_rev () =
  assert ([| 1; 2; 3; 4; 5 |] = Array.rev [| 5; 4; 3; 2; 1 |]);
  assert ([| 1; 2; 3; 4; 5; 6 |] = Array.rev [| 6; 5; 4; 3; 2; 1 |]);
  assert ([| "a"; "b"; "c" |] = Array.rev [| "c"; "b"; "a" |]);
  assert ([| "a"; "b" |] = Array.rev [| "b"; "a" |]);
  assert ([| "a" |] = Array.rev [| "a" |]);
  assert ([| |] = Array.rev [| |])

let test_rev_in_place () =
  let a = [| 5; 4; 3; 2; 1 |] in
  Array.rev_in_place a;
  assert ([| 1; 2; 3; 4; 5 |] = a);
  let a = [| 6; 5; 4; 3; 2; 1 |] in
  Array.rev_in_place a;
  assert ([| 1; 2; 3; 4; 5; 6 |] = a);
  let a = [| "c"; "b"; "a" |] in
  Array.rev_in_place a;
  assert ([| "a"; "b"; "c" |] = a);
  let a = [| "b"; "a" |] in
  Array.rev_in_place a;
  assert ([| "a"; "b" |] = a);
  let a = [| "a" |] in
  Array.rev_in_place a;
  assert ([| "a" |] = a);
  let a = [| |] in
  Array.rev_in_place a;
  assert ([| |] = a)

let test_for_all () =
  let a = [| 0; 2; 4; 6; 8; 10; 12 |] in
  let is_even i = 0 = (i land 1) in
  assert (Array.for_all is_even a);
  assert (Array.for_all is_even [| |])

let test_exists () =
  let a = [| 0; 2; 4; 6; 8; 10; 11; 12 |] in
  let b = [| 0; 2; 4; 6; 8; 10; 12 |] in
  let is_even i = 0 = (i land 1) in
  let is_odd i = 1 = (i land 1) in
  assert (Array.exists is_odd a);
  assert (not (Array.exists is_odd b));
  assert (not (Array.exists is_even [| |]))

let test_mem () =
  let a = [| 0; 2; 4; 6; 8; 10; 11; 12 |] in
  assert (Array.mem 11 a);
  assert (Array.mem 12 a);
  assert (not (Array.mem 13 a));
  assert (not (Array.mem 13 [| |]))

let test_memq () =
  let a = [| 0; 2; 4; 6; 8; 10; 11; 12 |] in
  assert (Array.memq 11 a);
  assert (Array.memq 12 a);
  assert (not (Array.memq 13 a));
  assert (not (Array.memq 13 [| |]))

let test_find () =
  let a = [| 0; 2; 4; 6; 8; 10; 11; 12 |] in
  assert (11 = Array.find ((=) 11) a);
  assert (12 = Array.find ((=) 12) a);
  assert (try ignore (Array.find ((=) 13) a); false with Not_found -> true);
  assert (try ignore (Array.find ((=) 13) [| |]); false with Not_found -> true)

let test_findi () =
  let a = [| 0; 2; 4; 6; 8; 10; 11; 12 |] in
  assert (6 = Array.findi ((=) 11) a);
  assert (7 = Array.findi ((=) 12) a);
  assert (try ignore (Array.findi ((=) 13) a); false with Not_found -> true);
  assert (try ignore (Array.findi ((=) 13) [| |]); false
	  with Not_found -> true)

let test_filter () =
  let a = [| 0; 1; 2; 3; 4; 5; 6; 7; 8; 9 |] in
  let is_even i = 0 = (i land 1) in
  let is_odd i = 1 = (i land 1) in
  assert ([| 0; 2; 4; 6; 8 |] = Array.filter is_even a);
  assert ([| 1; 3; 5; 7; 9 |] = Array.filter is_odd a);
  let a = Array.init 10_000 (fun i -> i) in
  let b = Array.init 5_000 (fun i -> i * 2) in
  let c = Array.init 5_000 (fun i -> i * 2 + 1) in
  assert (b = Array.filter is_even a);
  assert (c = Array.filter is_odd a);
  assert ([| |] = Array.filter is_even [| |])

let test_partition () =
  let a = [| 0; 1; 2; 3; 4; 5; 6; 7; 8; 9 |] in
  let is_even i = 0 = (i land 1) in
  let is_odd i = 1 = (i land 1) in
  let x, y = Array.partition is_even a in
  assert ([| 0; 2; 4; 6; 8 |] = x);
  assert ([| 1; 3; 5; 7; 9 |] = y);
  let x, y = Array.partition is_odd a in
  assert ([| 1; 3; 5; 7; 9 |] = x);
  assert ([| 0; 2; 4; 6; 8 |] = y);
  assert (([| |], [| |]) = Array.partition is_even [| |])

let test_enum () =
  let a = Array.init 1000 (fun i -> i) in
  let e = Array.enum a in
  let l = ExtList.List.of_enum e in
  assert (l = Array.to_list a);
  let l = ExtList.List.init 2000 (fun i -> i) in
  let e = ExtList.List.enum l in
  let a = Array.of_enum e in
  assert (a = Array.of_list l)

let test_map2 () =
  let a = Array.init 100 (fun i -> i) in
  let b = Array.init 100 (fun i -> 99 - i) in
  assert (Array.make 100 99 = Array.map2 (+) a b);
  assert (try let _ = Array.map2 (+) [||] [|1|] in false with Invalid_argument _ -> true);
  assert (Array.map2 (-) a b = Array.of_list (List.map2 (-) (Array.to_list a) (Array.to_list b)))

let () =
  Util.register "ExtArray" [
    "rev", test_rev;
    "rev_in_place", test_rev_in_place;
    "for_all", test_for_all;
    "exists", test_exists;
    "mem", test_mem;
    "memq", test_memq;
    "find", test_find;
    "findi", test_findi;
    "filter", test_filter;
    "partition", test_partition;
    "enum", test_enum;
    "map2", test_map2;
  ]
