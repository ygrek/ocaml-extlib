(* 
 * IOO - OO Wrappers for IO
 * Copyright (C) 2003 Nicolas Cannasse
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
open IO

class ['a,'b] o_input (ch:('a,'b) input) =
  object
	method read = read ch
	method nread n = nread ch n
	method pos = pos_in ch
	method available = available ch
	method close = close_in ch
  end

class ['a,'b,'c] o_output (ch:('a,'b,'c) output) =
  object
	method write x = write ch x
	method nwrite x = nwrite ch x
	method pos = pos_out ch
	method flush = flush ch
	method close = close_out ch
  end

let from_in ch =
	create_in
		~read:(fun () -> ch#read)
		~nread:ch#nread
		~pos:(fun () -> ch#pos)
		~available:(fun () -> ch#available)
		~close:(fun () -> ch#close)

let from_out ch =
	create_out
		~write:ch#write
		~nwrite:ch#nwrite
		~pos:(fun () -> ch#pos)
		~flush:(fun () -> ch#flush)
		~close:(fun () -> ch#close)

(** Generic IO **)

class in_channel ch =
  object
	method input s pos len = 
		let s' = nread ch len in
		let len = String.length s' in
		String.unsafe_blit s pos s' 0 len;
		len
	method close_in() = close_in ch
  end

class out_channel ch =
  object
	method output s pos len =
		let slen = String.length s in
		if pos = 0 && len = slen then nwrite ch s else nwrite ch (String.sub s pos len);
		len
	method flush() = flush ch
	method close_out() = ignore(close_out ch)
  end

class ['a] poly_in_channel (ch : ('a,'b) IO.input) =
  object
	method get() = try read ch with No_more_input -> raise End_of_file
	method close_in() = close_in ch
  end

class ['a] poly_out_channel (ch : ('a,'b,'c) IO.output) =
  object
	method put t = write ch t
	method flush() = flush ch
	method close_out() = ignore(close_out ch)
  end

let from_in_channel ch =
	let cbuf = String.create 1 in
	let read() =
		try
			if ch#input cbuf 0 1 = 0 then raise Sys_blocked_io;
			String.unsafe_get cbuf 0
		with
			End_of_file -> raise No_more_input
	in
	let nread n =
		let s = String.create n in
		let len = ch#input s 0 n in
		if len = n then s else String.sub s 0 len
	in
	create_in
		~read
		~nread
		~pos:(fun() -> raise Not_implemented)
		~available:(fun() -> raise Not_implemented)
		~close:ch#close_in

let from_out_channel ch =
	let cbuf = String.create 1 in
	let write c =
		String.unsafe_set cbuf 0 c;
		if ch#output cbuf 0 1 = 0 then raise Sys_blocked_io;
	in
	let nwrite s =
		let pos = ref 0 in
		let len = ref (String.length s) in
		while !len > 0 do
			let wlen = ch#output s !pos !len in
			if wlen = 0 then raise Sys_blocked_io;
			pos := !pos + wlen;
			len := !len - wlen
		done;
	in
	create_out
		~write
		~nwrite
		~pos:(fun() -> raise Not_implemented)
		~flush:ch#flush
		~close:ch#close_out

let from_poly_in_channel ch =	
	let rec nread n =
		if n = 0 then [] else 
			let c = ch#get() in
			c :: nread (n - 1)
	in
	create_in
		~read:ch#get
		~nread
		~pos:(fun() -> raise Not_implemented)
		~available:(fun() -> raise Not_implemented)
		~close:ch#close_in

let from_str_in_channel ch =	
	let nread n =
		let s = String.create n in
		let p = ref 0 in
		try
			while !p < n do		
				String.unsafe_set s !p (ch#get());
				incr p
			done;
			s
		with
			End_of_file when !p > 0-> 
				String.sub s 0 !p
	in
	create_in
		~read:ch#get
		~nread
		~pos:(fun() -> raise Not_implemented)
		~available:(fun() -> raise Not_implemented)
		~close:ch#close_in

let from_poly_out_channel ch =
	let rec nwrite = function
		| [] -> ()
		| x :: l ->
			ch#put x;
			nwrite l
	in
	create_out
		~write:ch#put
		~nwrite
		~pos:(fun() -> raise Not_implemented)
		~flush:ch#flush
		~close:ch#close_out

let from_str_out_channel ch =
	let nwrite s =
		let l = String.length s - 1 in
		for i = 0 to l do
			ch#put (String.unsafe_get s i)
		done
	in
	create_out
		~write:ch#put
		~nwrite
		~pos:(fun() -> raise Not_implemented)
		~flush:ch#flush
		~close:ch#close_out
