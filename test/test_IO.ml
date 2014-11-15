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

(* NOTE The IO module test case was contributed by Robert Atkey on
   ocaml-lib-devel@lists.sourceforge.net on Nov 26, 2007.  
   Thanks Rob! *)

let test_write_i16 () =
  (* Bug was that write_i16 did not accept -0x8000 *)
  let out = IO.output_string () in
  let ()  =
    try 
      (* -32768 is a valid 16-bit signed int *)
      IO.write_i16 out (-0x8000)
    with 
      IO.Overflow _ -> 
        assert false
  in
  let ()  =
    try 
      (* Ditto for BigEndian *)
      IO.BigEndian.write_i16 out (-0x8000)
    with IO.Overflow _ -> 
      assert false
  in
  let _ = IO.close_out out in
    ()

let () = 
  Util.register1 "IO" "write_i16" test_write_i16

