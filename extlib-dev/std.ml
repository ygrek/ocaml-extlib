(*
 * Std - Additional functions
 * Copyright (C) 2003 Nicolas Cannasse
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
	Enum.from (fun () -> try input_line ch with End_of_file -> raise Enum.No_more_elements)

let input_chars ch =
	Enum.from (fun () -> try input_char ch with End_of_file -> raise Enum.No_more_elements)

let input_list ch =
	let rec loop dst =
		let r = [ input_line ch ] in
		Obj.magic (Obj.repr dst) 1 (Obj.repr r);
		loop r
	in
	let r = [ Obj.magic () ] in
	try
		loop r
	with
		End_of_file ->
			match r with
			| x :: l -> l
			| [] -> assert false


let buf_len = 8192
let static_buf = String.create buf_len

let input_all ch =
	let buf = Buffer.create 0 in
	let rec loop() =
		match input ch static_buf 0 buf_len with
		| 0 -> Buffer.contents buf
		| len ->
			Buffer.add_substring buf static_buf 0 len;
			loop()
	in
	loop()

let print_bool = function
	| true -> print_string "true"
	| false -> print_string "false"

let prerr_bool = function
	| true -> prerr_string "true"
	| false -> prerr_string "false"

