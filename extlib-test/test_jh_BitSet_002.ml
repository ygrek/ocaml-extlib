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

open ExtList

module B = BitSet

let biased_rnd_28 () = 
  let n_bits = [| 4; 8; 16; 28 |] in
  let n = n_bits.(Random.int (Array.length n_bits)) in
  Random.int (1 lsl n)

let popcount n = 
  let p = ref 0 in
  for i = 0 to 29 do
    if n land (1 lsl i) <> 0 then
      incr p
  done;
  !p

let set_bitset s n = 
  for i = 0 to 29 do
    if (n land (1 lsl i)) <> 0 then
      B.set s i
  done;
  assert (popcount n = B.count s)

let bitset_of_int n = 
  assert (n <= (1 lsl 29));
  let s = B.create 30 in
  set_bitset s n;
  s

let int_of_bitset s = 
  let n = ref 0 in
  for i = 0 to 29 do
    if B.is_set s i then
      n := !n lor (1 lsl i)
  done;
  !n

let bitset_of_int_scale n scl = 
  assert (n <= (1 lsl 29));
  let s = B.create 30 in
  for i = 0 to 29 do
    if (n land (1 lsl i)) <> 0 then
      B.set s (i*scl)
  done;
  assert (popcount n = B.count s);
  s

let int_of_bitset_scale s scl = 
  let n = ref 0 in
  for i = 0 to 29 do
    if B.is_set s (i*scl) then
      n := !n lor (1 lsl i)
  done;
  !n

let test_unite () =
  for i = 0 to 255 do
    let r1 = biased_rnd_28 () in
    let s = bitset_of_int r1 in
    let c = B.copy s in
    assert (int_of_bitset s = r1);
    let pop = B.count c in
    B.unite c (B.empty ());
    assert (B.count c = pop);
  done


let test_intersect () =
  for i = 0 to 255 do
    let r1 = biased_rnd_28 () in
    let s = bitset_of_int r1 in
    let c = B.copy s in
    assert (int_of_bitset s = r1);
    B.intersect c (B.empty ());
    assert (B.count c = 0);
  done

let test_differentiate () = 
  for i = 0 to 255 do
    let r1 = biased_rnd_28 () in
    let s = bitset_of_int r1 in
    let d = B.copy s in
    B.differentiate d s;
    assert (B.count d = 0);
    for j = 0 to 32 do
      B.set s (Random.int 256)
    done;
    let d = B.copy s in
    B.differentiate d (B.empty ());
    assert (B.count s = B.count d);
    assert (B.compare d s = 0);
    B.differentiate d s;
    assert (B.count d = 0);
  done

(* TODO *)
let test_differentiate_sym () = 
  for i = 0 to 255 do
    let r1 = biased_rnd_28 () in
    let r2 = biased_rnd_28 () in
    let s = bitset_of_int r1 in
    let d = B.copy s in
    B.differentiate_sym d s;
    assert (B.count d = 0);
    for j = 0 to 32 do
      B.set s (Random.int 256)
    done;
    let d = B.copy s in
    B.differentiate_sym d (B.empty ());
    assert (B.count s = B.count d);
    assert (B.compare d s = 0);
    B.differentiate_sym d s;
    assert (B.count d = 0);

    let s1 = bitset_of_int r1 
    and s2 = bitset_of_int r2 in
    let d1 = B.copy s1 in
    B.differentiate_sym d1 s2;
    assert (r1 lxor r2 = int_of_bitset d1);
  done

let test () =
  Util.run_test ~test_name:"jh_BitSet_002.test_unite" test_unite;
  Util.run_test ~test_name:"jh_BitSet_002.test_intersect" test_intersect;
  Util.run_test ~test_name:"jh_BitSet_002.test_differentiate" test_differentiate;
  Util.run_test ~test_name:"jh_BitSet_002.test_differentiate_sym" 
    test_differentiate_sym;
