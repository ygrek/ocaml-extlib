(*
 * Std - Additional functions
 * Copyright (C) 2003 Nicolas Cannasse and Markus Mottl
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
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

let input_lines ch =
  Enum.from (fun () ->
    try input_line ch with End_of_file -> raise Enum.No_more_elements)

let input_chars ch =
  Enum.from (fun () ->
    try input_char ch with End_of_file -> raise Enum.No_more_elements)

let input_list ch =
  let rec loop dst =
    let r = [ input_line ch ] in
    Obj.magic (Obj.repr dst) 1 (Obj.repr r);
    loop r in
  let r = [ Obj.magic () ] in
  try loop r
  with
    End_of_file ->
      match r with
      | _ :: l -> l
      | [] -> assert false

let buf_len = 8192

let input_all ic =
  let rec loop acc total buf ofs =
    let n = input ic buf ofs (buf_len - ofs) in
    if n = 0 then
      let res = String.create total in
      let pos = total - ofs in
      let _ = String.blit buf 0 res pos ofs in
      let coll pos buf =
        let new_pos = pos - buf_len in
        String.blit buf 0 res new_pos buf_len;
        new_pos in
      let _ = List.fold_left coll pos acc in
      res
    else
      let new_ofs = ofs + n in
      let new_total = total + n in
      if new_ofs = buf_len then
        loop (buf :: acc) new_total (String.create buf_len) 0
      else loop acc new_total buf new_ofs in
  loop [] 0 (String.create buf_len) 0

let print_bool = function
  | true -> print_string "true"
  | false -> print_string "false"

let prerr_bool = function
  | true -> prerr_string "true"
  | false -> prerr_string "false"
