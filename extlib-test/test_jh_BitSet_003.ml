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

let test_bs_1 () = 
  let b = BitSet.empty () in
  BitSet.set b 8;
  BitSet.set b 9;
  assert (not (BitSet.is_set b 7));
  assert (BitSet.is_set b 8);
  assert (BitSet.is_set b 9);
  assert (not (BitSet.is_set b 10));
  ()

let test_enum_1 () = 
  let b = BitSet.empty () in
  BitSet.set b 0;
  BitSet.set b 1;
  let e = BitSet.enum b in
  let a = Enum.get e in
  let b = Enum.get e in
  assert (Option.get a = 0);
  assert (Option.get b = 1);
  ()

let test_enum_2 () = 
  let n = 13 in
  let b = BitSet.empty () in
  for i = 0 to n do
    BitSet.set b i
  done;
  let e = BitSet.enum b in
  for i = 0 to n do
    let a = Enum.get e in
    match a with
      Some v -> assert (v = i)
    | None -> assert false
  done;
  assert (Enum.get e = None);
  ()

let test_enum_3 () = 
  let b = BitSet.empty () in
  BitSet.set b 9;
  BitSet.set b 10;
  let e = BitSet.enum b in
  let i = Enum.get e in
  let j = Enum.get e in
  assert (Option.get i = 9);
  begin
    match j with
      Some v -> 
        assert (v = 10);
    | None -> 
        assert false (* Should NOT come here! *)
  end;
  assert (Enum.get e = None);
  ()

(* Bug reported by Pascal Zimmer on Feb 27, 2007.  The latter assert
   returned None when it should've returned Some 9. *)
let test_enum_regr_pz () = 
  let b = BitSet.empty () in
  BitSet.set b 8;
  BitSet.set b 9;
  let e = BitSet.enum b in
  let i = Enum.get e in
  let j = Enum.get e in
  assert (Option.get i = 8);
  begin
    match j with
      Some v -> 
        assert (v = 9);
    | None -> 
        assert false (* Should NOT come here! *)
  end;
  ()


let test () =
  Util.run_test ~test_name:"jh_BitSet_003.test_bs_1" test_bs_1;
  Util.run_test ~test_name:"jh_BitSet_003.test_enum_1" test_enum_1;
  Util.run_test ~test_name:"jh_BitSet_003.test_enum_2" test_enum_2;
  Util.run_test ~test_name:"jh_BitSet_003.test_enum_3" test_enum_3;
  Util.run_test ~test_name:"jh_BitSet_003.test_enum_regr_pz" test_enum_regr_pz
