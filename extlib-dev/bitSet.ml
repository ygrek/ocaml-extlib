(*
 * Bitset - Efficient bit sets
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

type intern

external bcreate : int -> intern = "create_string"
external blen : intern -> int = "%string_length"
external bget : intern -> int -> int = "%string_unsafe_get"
external bset : intern -> int -> int -> unit = "%string_unsafe_set"
external fast_bool : int -> bool = "%identity"

exception Negative_index of string

type t = intern ref

let error fname = raise (Negative_index fname)

let empty() =
	ref (bcreate 0)

let create n =
	if n < 0 then error "create";
	let size = (n+7) lsl 3 in
	let b = bcreate size in
	for i = 0 to size - 1 do
		bset b i 0
	done;
	ref b

let clone t =
	let size = blen !t in
	let b = bcreate size in
	for i = 0 to size - 1 do
		bset b i (bget !t i)
	done;
	ref b

let set t x =
	if x < 0 then error "set";
	let pos , delta = x lsr 3 , x land 7 in
	let size = blen !t in
	if pos >= size then begin
		let b = bcreate (pos+1) in
		for i = 0 to size - 1 do
			bset b i (bget !t i)
		done;
		for i = size to pos do
			bset b i 0
		done;
		t := b;
	end;
	bset !t pos ((bget !t pos) lor (1 lsl delta))

let unset t x =
	if x < 0 then error "unset";
	let pos , delta = x lsr 3 , x land 7 in
	let size = blen !t in
	if pos < size then
		bset !t pos ((bget !t pos) land (0xFF lxor (1 lsl delta)))

let toggle t x =
	if x < 0 then error "toggle";
	let pos , delta = x lsr 3 , x land 7 in
	let size = blen !t in
	if pos >= size then begin
		let b = bcreate (pos+1) in
		for i = 0 to size - 1 do
			bset b i (bget !t i)
		done;
		for i = size to pos do
			bset b i 0
		done;
		t := b;
	end;
	bset !t pos ((bget !t pos) lxor (1 lsl delta))

let put t = function
	| true -> set t
	| false -> unset t

let is_set t x =
	let pos , delta = x lsr 3 , x land 7 in
	let size = blen !t in
	if pos < size then
		fast_bool (((bget !t pos) lsr delta) land 1)
	else
		false

let compare t1 t2 =
	let size1 , size2 = blen !t1 , blen !t2 in
	let size = (if size1 < size2 then size1 else size2) in
	let rec loop2 n =
		if n >= size2 then
			0
		else if bget !t2 n <> 0 then
			1
		else
			loop2 (n+1)
	in
	let rec loop1 n =
		if n >= size1 then
			0
		else if bget !t1 n <> 0 then
			-1
		else
			loop1 (n+1)
	in
	let rec loop n =
		if n = size then
			(if size1 > size2 then loop1 n else loop2 n)
		else
			let d = bget !t2 n - bget !t1 n in
			if d = 0 then
				loop (n+1)
			else if d < 0 then
				-1
			else
				1
	in
	loop 0

let equals t1 t2 =
	compare t1 t2 = 0

let partial_count t x =
	let rec nbits x =
		if x = 0 then
			0
		else if fast_bool (x land 1) then
			1 + (nbits (x lsr 1))
		else
			nbits (x lsr 1)
	in
	let size = blen !t in
	let pos , delta = x lsr 3, x land 7 in
	let rec loop n acc =
		if n = size then
			acc
		else
			let x = bget !t n in
			loop (n+1) (acc + nbits x)
	in
	if pos >= size then
		0
	else
		loop (pos+1) (nbits ((bget !t pos) lsr delta))

let count t =
	partial_count t 0

let enum t =
	let rec make n =
		let cur = ref n in
		let rec next() =
			let pos , delta = !cur lsr 3, !cur land 7 in
			if pos >= blen !t then raise Enum.No_more_elements;
			let x = bget !t pos in
			let rec loop i =
				if i = 8 then
					next()
				else if x land (1 lsl i) = 0 then begin
					incr cur;
					loop (i+1)
				end else
					!cur
			in
			let b = loop delta in
			incr cur;
			b
		in
		Enum.make
			~next
			~count:(fun () -> partial_count t !cur)
			~clone:(fun () -> make !cur)
	in
	make 0


				