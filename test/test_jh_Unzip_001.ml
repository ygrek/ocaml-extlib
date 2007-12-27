(*
 * ExtLib Testing Suite
 * Copyright (C) 2004, 2007 Janne Hellsten
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

(* test_unzip_bug1 test case was contributed by Robert Atkey on
   ocaml-lib-devel@lists.sourceforge.net on Nov 26, 2007.  
   Thanks Rob! *)

let test_unzip_bug1 () =
  let test data =
    let input    = IO.input_string data in
    let unzipped = Unzip.inflate input in
    try
      let str      = IO.read_all unzipped in
      assert (str = "XY")
    with Unzip.Error Unzip.Invalid_data -> assert false
  in
  (* this is "XY" compressed by zlib at level 9 *)
  test "\x78\xda\x8b\x88\x04\x00\x01\x0b\x00\xb2";
  (* this is "XY" compressed by zlib at level 0 *)
  test "\x78\x01\x01\x02\x00\xfd\xff\x58\x59\x01\x0b\x00\xb2"

let test () = 
  Util.run_test ~test_name:"jh_Unzip.unzip_bug1" test_unzip_bug1
