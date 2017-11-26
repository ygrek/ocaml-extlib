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

let test_write_read write read values invalid =
  let s = IO.output_string () in
  List.iter begin fun x ->
    if try write s x; true with IO.Overflow _ -> false then fail "write %d expected to fail, but didn't" x
  end invalid;
  List.iter begin fun i ->
    try write s i with exn -> fail "failed to write %d : %s" i (Printexc.to_string exn)
  end values;
  let s = IO.close_out s in
  let s = IO.input_string s in
  List.iter begin fun expect ->
    let i = read s in
    if i <> expect then fail "failed to read %d : got %d" expect i
  end values;
  match IO.read_all s with
  | "" -> ()
  | s -> fail "expected empty input, got %S" s

let test_i16 () =
  (* Bug was that write_i16 did not accept -0x8000 *)
  let values = [~-0x8000;-1;0;1;0x7FFF] in
  let invalid = [~-0x8001;0x8000] in
  test_write_read IO.write_i16 IO.read_i16 values invalid;
  test_write_read IO.BigEndian.write_i16 IO.BigEndian.read_i16 values invalid;
  ()

let () =
  Util.register1 "IO" "i16" test_i16
