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
  (* This string represents an uncompressed block. 
     0x80 : bit 8 is set to indicate the last block,
            bits 6 and 7 are 00 to indicate an uncompressed block
            all other bits are ignored
     0x02
     0x00 : length of data (2) in little endian
     0xfd
     0xff : one's complement of data length (little endian)
     X
     Y    : the data

     The bug is that the Unzip module incorrectly checked that the
     one's complement representation of the length matched the
     original length. *)
  let block    = "\x80\x02\x00\xfd\xffXY" in
  let input    = IO.input_string block in
  let unzipped = Unzip.inflate ~header:false input in
    try
      let str      = IO.really_nread unzipped 2 in
      assert (str = "XY")
    with Unzip.Error Unzip.Invalid_data -> 
      assert false

let test () = 
  Util.run_test ~test_name:"jh_Unzip.unzip_bug1" test_unzip_bug1
