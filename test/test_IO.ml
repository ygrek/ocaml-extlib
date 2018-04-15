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

let fail fmt = Printf.ksprintf failwith fmt

let test_write_read values invalid show write read =
  let s = IO.output_string () in
  List.iter begin fun x ->
    if try write s x; true with IO.Overflow _ -> false then fail "write %s expected to fail, but didn't" (show x)
  end invalid;
  List.iter begin fun i ->
    try write s i with exn -> fail "failed to write %s : %s" (show i) (Printexc.to_string exn)
  end values;
  let s = IO.close_out s in
  let s = IO.input_string s in
  List.iter begin fun expect ->
    let i = read s in
    if i <> expect then fail "failed to read %s : got %s" (show expect) (show i)
  end values;
  match IO.read_all s with
  | "" -> ()
  | s -> fail "expected empty input, got %S" s

let test_i8 () =
  let values = [~-0x80;-1;0;1;0x7F] in
  let invalid = [] in (* never fails - truncates *)
  test_write_read values invalid string_of_int IO.write_byte IO.read_signed_byte;
  ()

let test_u8 () =
  let values = [0;1;0xFF] in
  let invalid = [] in (* never fails *)
  test_write_read values invalid string_of_int IO.write_byte IO.read_byte;
  ()

let test_i16 () =
  (* Bug was that write_i16 did not accept -0x8000 *)
  let values = [~-0x8000;-1;0;1;0x7FFF] in
  let invalid = [~-0x8001;0x8000] in
  let test = test_write_read values invalid string_of_int in
  test IO.write_i16 IO.read_i16;
  test IO.BigEndian.write_i16 IO.BigEndian.read_i16;
  ()

let test_u16 () =
  let values = [0;1;0xFFFF] in
  let invalid = [~-1;0x10000] in
  let test = test_write_read values invalid string_of_int in
  test IO.write_ui16 IO.read_ui16;
  test IO.BigEndian.write_ui16 IO.BigEndian.read_ui16;
  ()

let test_i31 () =
  let values = [~-0x4000_0000;-1;0;1;0x3FFF_FFFF] in
  let invalid = if Sys.word_size = 32 then [] else [~-0x4000_0001;0x4000_0000] in
  let test = test_write_read values invalid string_of_int in
  test IO.write_i31 IO.read_i31;
  test IO.BigEndian.write_i31 IO.BigEndian.read_i31;
  ()

let test_i32 () =
  let min_i32 = Int32.to_int Int32.min_int in
  let max_i32 = Int32.to_int Int32.max_int in
  let values = [~-0x4000_0000;-1;0;1;0x3FFF_FFFF] @ if Sys.word_size = 32 then [] else [min_i32;max_i32] in
  let invalid = if Sys.word_size = 32 then [] else [min_i32-1;max_i32+1] in
  let test = test_write_read values invalid string_of_int in
  test IO.write_i32 IO.read_i32_as_int;
  test IO.BigEndian.write_i32 IO.BigEndian.read_i32_as_int;
  ()

let test_real_i32 () =
  let values = [Int32.min_int;-1l;0l;1l;Int32.max_int] in
  let invalid = [] in
  let test = test_write_read values invalid Int32.to_string in
  test IO.write_real_i32 IO.read_real_i32;
  test IO.BigEndian.write_real_i32 IO.BigEndian.read_real_i32;
  ()

let () =
  Util.register1 "IO" "i32" test_i32;
  Util.register1 "IO" "real_i32" test_real_i32;
  Util.register1 "IO" "i31" test_i31;
  Util.register1 "IO" "u16" test_u16;
  Util.register1 "IO" "i16" test_i16;
  Util.register1 "IO" "u8" test_u8;
  Util.register1 "IO" "i8" test_i8;
  ()
