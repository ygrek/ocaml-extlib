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

module P = Printf

let log s = 
  P.printf "%s\n" s;
  flush stdout

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

(* For  counting the success ratio *)
let test_run_count = ref 0 
let test_success_count = ref 0 
let g_test_run_count = ref 0 
let g_test_success_count = ref 0 

let test_module name f = 
  P.printf "%s\n" name;
  flush stdout;
  test_run_count := 0;
  test_success_count := 0;
  f ();
  if !test_run_count <> 0 then
    P.printf "  %i/%i tests succeeded.\n" 
      !test_success_count !test_run_count

let run_test ~test_name f = 
  try
    incr g_test_run_count;
    incr test_run_count;
    P.printf "  %s" test_name;
    flush stdout;
    let () = f () in
    incr g_test_success_count;
    incr test_success_count;
    P.printf " - OK\n"
  with 
    Assert_failure (file,line,column) ->
      P.printf " - FAILED\n    reason: ";
      P.printf " %s:%i:%i\n" file line column;
      flush stdout

let all_tests = Hashtbl.create 10

let register modname l =
  let existing = try Hashtbl.find all_tests modname with Not_found -> [] in
  Hashtbl.replace all_tests modname (l @ existing)

let register1 modname name f = register modname [name,f]

let run_all filter =
  let allowed name =
    match filter with
    | None -> true
    | Some l -> List.mem (String.lowercase name) l
  in
  g_test_run_count := 0;
  g_test_success_count := 0;
  Hashtbl.iter begin fun modname tests ->
    let allowed_module = allowed modname in
    test_module modname begin fun () ->
      List.iter begin fun (test_name,f) ->
        if allowed_module || allowed (modname^"."^test_name) then run_test ~test_name f
      end tests
    end
  end all_tests;
  if !g_test_run_count <> 0 then
    P.printf "\nOverall %i/%i tests succeeded.\n" 
      !g_test_success_count !g_test_run_count;
  !g_test_run_count = !g_test_success_count
