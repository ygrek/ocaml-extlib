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

let log s = 
  Printf.printf "%s\n" s

let random_char () = 
  char_of_int (Random.int 256)

let random_string () = 
  let len = Random.int 256 in
  let str = String.create len in
  if len > 0 then
    for i = 0 to (len-1) do
      str.[i] <- random_char ()
    done;
  str


let random_string_len len = 
  let len = len in
  let str = String.create len in
  if len > 0 then
    for i = 0 to (len-1) do
      str.[i] <- random_char ()
    done;
  str

let run_test ?(test_name="<unknown>") f = 
  try
    Printf.printf "\nrun: %s" test_name;
    flush stdout;
    f ();
  with 
    Assert_failure (file,line,column) ->
      Printf.printf " ..FAILED\n  reason:\n";
      Printf.printf "%s:%i:%i test %s failed\n" file line column test_name;
      flush stdout
