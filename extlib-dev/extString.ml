(*
 * ExtString - Additional functions for string manipulations.
 * Copyright (C) 2003 Nicolas Cannasse
 * 
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version,,
 * with the special exception on linking described in file LICENCE.
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

module String = struct

exception Invalid_string

include String

let init len f =
	let s = create len in
	for i = 0 to len - 1 do
		unsafe_set s i (f i)
	done;
	s

let starts_with str p =
	let len = length p in
	if length str < len then 
		false
	else
		sub str 0 len = p

let ends_with s e =
	let el = length e in
	let sl = length s in
	if sl < el then
		false
	else
		sub s (sl-el) el = e

let find str sub =
	let sublen = length sub in
	if sublen = 0 then
		0
	else
		let found = ref 0 in
		let len = length str in
		try
			for i = 0 to len - sublen do
				let j = ref 0 in
				while unsafe_get str (i + !j) = unsafe_get sub !j do
					incr j;
					if !j = sublen then begin found := i; raise Exit; end;
				done;
			done;
			raise Invalid_string
		with
			Exit -> !found

let strip ?(chars=" \t\r\n") s =
	let p = ref 0 in
	let l = length s in
	while !p < l && contains chars (unsafe_get s !p) do
		incr p;
	done;
	let p = !p in
	let l = ref (l - 1) in
	while !l >= p && contains chars (unsafe_get s !l) do
		decr l;
	done;
	sub s p (!l - p + 1)

let split str sep =
	let p = find str sep in
	let len = length sep in
	let slen = length str in
	sub str 0 p, sub str (p + len) (slen - p - len)

let rec nsplit str sep =
	try
		let s1 , s2 = split str sep in
		s1 :: nsplit s2 sep
	with
		Invalid_string -> [str]

let join = concat

let lchop s =
	if s = "" then "" else sub s 1 (length s - 1)

let rchop s =
	if s = "" then "" else sub s 0 (length s - 1)

let of_int = string_of_int

let of_float = string_of_float

let of_char = make 1

let to_int s =
	try
		int_of_string s
	with
		_ -> raise Invalid_string

let to_float s =
	try
		float_of_string s
	with
		_ -> raise Invalid_string

let enum s =
	let l = length s in
	let rec make i =
		Enum.make 
		~next:(fun () ->
			if !i = l then
				raise Enum.No_more_elements
			else
				let p = !i in
				incr i;
				unsafe_get s p
			)
		~count:(fun () -> l - !i)
		~clone:(fun () -> make (ref !i))
	in
	make (ref 0)

let of_enum e =
	let l = Enum.count e in
	let s = create l in
	let i = ref 0 in
	Enum.iter (fun c -> unsafe_set s !i c; incr i) e;
	s

let map f s =
	let len = length s in
	let sc = create len in
	for i = 0 to len - 1 do
		unsafe_set sc i (f (unsafe_get s i))
	done;
	sc

end
