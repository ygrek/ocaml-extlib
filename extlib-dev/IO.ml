(* 
 * IO - Abstract input/output
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

type ('a,'b) input = {
	mutable in_read : unit -> 'a;
	mutable in_nread : int -> 'b;
	mutable in_available : unit -> int;
	mutable in_close : unit -> unit;
	mutable in_pos : unit -> int;
}

type ('a,'b,'c) output = {
	mutable out_write : 'a -> unit;
	mutable out_nwrite : 'b -> unit;
	mutable out_close : unit -> 'c;
	mutable out_flush : unit -> unit;
	mutable out_pos : unit -> int;
}

type stdin = (char, string) input
type 'a stdout = (char, string,'a) output

exception No_more_input
exception Input_closed
exception Output_closed
exception Not_implemented

(* -------------------------------------------------------------- *)
(* API *)

let default_available = (fun () -> raise Not_implemented)
let default_close = (fun () -> ())

let create_in ~read ~nread ~pos ~available ~close =
	{
		in_read = read;
		in_nread = nread;
		in_available = available;
		in_close = close;
		in_pos = pos;
	}

let create_out ~write ~nwrite ~pos ~flush ~close =
	{
		out_write = write;
		out_nwrite = nwrite;
		out_close = close;
		out_flush = flush;
		out_pos = pos;
	}

let read i = i.in_read()
let nread i n = 
	if n < 0 then raise (Invalid_argument "IO.nread");
	i.in_nread n

let pos_in i = i.in_pos()
let available i = i.in_available()
let close_in i = 
	let f _ = raise Input_closed in
	i.in_close();
	i.in_read <- f;
	i.in_nread <- f;
	i.in_available <- (fun () -> 0);
	i.in_close <- f

let write o x = o.out_write x
let nwrite o x = o.out_nwrite x
let pos_out o = o.out_pos()

let printf o fmt =
	Printf.kprintf (fun s -> nwrite o s) fmt

let flush o = o.out_flush()

let close_out o =
	let r = o.out_close() in
	let f _ = raise Output_closed in
	o.out_write <- f;
	o.out_nwrite <- f;
	o.out_close <- f;
	o.out_flush <- f;
	r

(* -------------------------------------------------------------- *)
(* Standard IO *)

let input_string s =
	let pos = ref 0 in
	let len = String.length s in
	{
		in_read = (fun () ->
			if !pos >= len then raise No_more_input;
			let c = String.unsafe_get s !pos in
			incr pos;
			c
		);
		in_nread = (fun n ->
			if n = 0 then
				""
			else begin
				if !pos >= len then raise No_more_input;
				let n = (if !pos + n > len then len - !pos else n) in
				let s = String.sub s !pos n in
				pos := !pos + n;
				s
			end;
		);
		in_available = (fun () -> len - !pos);		
		in_close = (fun () -> ());
		in_pos = (fun () -> !pos);
	}

let output_string() =
	let b = Buffer.create 0 in
	{
		out_write = (fun c ->
			Buffer.add_char b c
		);
		out_nwrite = (fun s ->
			Buffer.add_string b s;
		);
		out_close = (fun () -> Buffer.contents b);
		out_flush = (fun () -> ());
		out_pos = (fun () -> Buffer.length b);
	}

let input_channel ch =
	{
		in_read = (fun () ->
			try
				input_char ch
			with
				End_of_file -> raise No_more_input
		);
		in_nread = (fun n ->
			if n = 0 then
				""
			else
				let s = String.create n in
				let rec loop pos len =
					try
						let nr = input ch s pos len in
						if nr <= 0 then raise End_of_file;
						if nr = len then
							s
						else
							loop (pos + nr) (len - nr)
					with
						End_of_file -> 
							if pos = 0 then raise No_more_input;
							String.sub s 0 pos
				in
				loop 0 n
		);
		in_available = (fun () ->
			try
				in_channel_length ch - Pervasives.pos_in ch
			with
				_ -> raise Not_implemented
		);
		in_close = (fun () -> Pervasives.close_in ch);
		in_pos = (fun () -> Pervasives.pos_in ch);
	}

let output_channel ch =
	{
		out_write = (fun c -> output_char ch c);
		out_nwrite = (fun s -> Pervasives.output_string ch s);
		out_close = (fun () -> Pervasives.close_out ch);
		out_flush = (fun () -> Pervasives.flush ch);
		out_pos = (fun () -> Pervasives.pos_out ch);
	}

let input_enum e =
	let pos = ref 0 in
	{
		in_read = (fun () ->
			match Enum.get e with
			| None -> raise No_more_input
			| Some x -> 
				incr pos;
				x
		);
		in_nread = (fun n ->
			if n = 0 then
				Enum.empty()
			else
				let p = ref 0 in
				let elts = DynArray.make n in
				try
					ignore(Enum.find (fun x -> DynArray.unsafe_set elts !p x; incr p; incr pos; !p = n) e);					
					DynArray.enum elts
				with
					Not_found -> 
						if !p = 0 then raise No_more_input;
						DynArray.enum elts
		);
		in_available = (fun () -> Enum.count e);
		in_close = (fun () -> ());
		in_pos = (fun () -> !pos);
	}

let output_enum() =
	let elts = DynArray.create() in
	{
		out_write = (fun x ->
			DynArray.add elts x
		);
		out_nwrite = (fun e ->
			Enum.iter (DynArray.add elts) e
		);
		out_close = (fun () ->
			DynArray.enum elts
		);
		out_flush = (fun () -> ());
		out_pos = (fun () -> DynArray.length elts);
	}

type 'a queue = {
	cur : 'a;
	mutable next : 'a queue;
}

let pipe() =
	let read = ref 0 in
	let written = ref 0 in
	let n = ref 0 in
	let empty = ((Obj.magic None) : 'a queue) in
	let head = ref empty in
	let tail = ref empty in
	let get() =	
		let q = !head in
		head := q.next;
		incr read;		
		q.cur
	in
	let rec nget n = 
		if n = 0 then [] else (get()) :: nget (n-1)
	in
	let put x =
		let q = { cur = x; next = empty } in
		if !n = 0 then begin
			head := q;
			tail := q;
		end else begin
			(!tail).next <- q;
			tail := q;
		end;
		incr n;
		incr written;
	in
	let input = {
		in_read = (fun () -> 
			if !n = 0 then raise No_more_input;
			n := !n - 1;
			get()
		);
		in_nread = (fun nr ->
			if !n = 0 then raise No_more_input;
			let nr = (if !n > nr then nr else !n) in
			n := !n - nr;
			nget nr
		);
		in_pos = (fun () -> !read);
		in_close = (fun () -> ());
		in_available = (fun () -> !n);
	} in
	let output = {
		out_write = (fun x -> put x);
		out_nwrite = (fun xl -> List.iter put xl);
		out_close = (fun () -> 
			let ret = ((Obj.magic !head) : 'a list) in
			head := empty;
			tail := empty;
			n := 0;
			ret
		);
		out_flush = (fun () -> ());
		out_pos = (fun () -> !written);
	} in
	input , output

(* -------------------------------------------------------------- *)
(* STDIO APIs *)

exception Overflow of string

let read_byte i = int_of_char (read i)

let read_string i =
	let b = Buffer.create 8 in
	let rec loop() =
		let c = read i in
		if c <> '\000' then begin
			Buffer.add_char b c;
			loop();
		end;
	in
	loop();
	Buffer.contents b

let read_line i =
	let b = Buffer.create 8 in
	let cr = ref false in
	let rec loop() =
		let c = read i in
		match c with
		| '\n' ->
			()
		| '\r' ->
			cr := true;
			loop()
		| _ when !cr ->
			cr := false;
			Buffer.add_char b '\r';
			Buffer.add_char b c;
			loop();
		| _ -> 
			Buffer.add_char b c;
			loop();
	in
	try
		loop();
		Buffer.contents b
	with
		No_more_input ->
			if !cr then Buffer.add_char b '\r';
			if Buffer.length b > 0 then
				Buffer.contents b
			else
				raise No_more_input

let read_ui16 i =
	let ch1 = read_byte i in
	let ch2 = read_byte i in
	ch1 lor (ch2 lsl 8)

let read_i16 i =
	let ch1 = read_byte i in
	let ch2 = read_byte i in
	let n = ch1 lor (ch2 lsl 8) in
	if ch2 land 128 > 0 then
		n - 65536
	else
		n

let read_i32 ch =
	let ch1 = read_byte ch in
	let ch2 = read_byte ch in
	let ch3 = read_byte ch in
	let ch4 = read_byte ch in
	if ch4 land 64 <> 0 then raise (Overflow "read_i32");
	if ch4 land 128 <> 0 then
		ch1 lor (ch2 lsl 8) lor (ch3 lsl 16) lor (((ch4 land 63) lor 64) lsl 24)
	else
		ch1 lor (ch2 lsl 8) lor (ch3 lsl 16) lor (ch4 lsl 24)

let write_byte o n =
	(* doesn't test bounds of n in order to keep semantics of Pervasives.output_byte *)
	write o (Char.unsafe_chr (n land 0xFF))

let write_string o s =
	nwrite o s;
	write o '\000'

let write_line o s =
	nwrite o s;
	write o '\n'

let write_ui16 ch n =
	if n < 0 || n > 0xFFFF then raise (Overflow "write_ui16");
	write_byte ch n;
	write_byte ch (n lsr 8)

let write_i16 ch n =
	if n < -0x7FFF || n > 0x7FFF then raise (Overflow "write_i16");
	if n < 0 then 
		write_ui16 ch (65536 + n)
	else
		write_ui16 ch n

let write_i32 ch n =
	write_byte ch n;
	write_byte ch (n lsr 8);
	write_byte ch (n lsr 16);
	write_byte ch (n asr 24)

(* -------------------------------------------------------------- *)
(* BITS APIS *)

let input_bits ch =
	let data = ref 0 in
	let count = ref 0 in
	let rec read n =
		if !count >= n then begin
			let c = !count - n in
			let k = (!data asr c) land ((1 lsl n) - 1) in
			count := c;
			k
		end else begin
			if !count >= 24 then raise (Overflow "read bits");
			let k = read_byte ch in
			data := (!data lsl 8) lor k;
			count := !count + 8;
			read n
		end
	in
	create_in 
		~read:(fun () -> read 1 = 1)
		~nread:read
		~pos:(fun () -> pos_in ch * 8 - !count)
		~available:(fun () -> (available ch) * 8 + !count)
		~close:(fun () -> close_in ch)

let output_bits ch =
	let data = ref 0 in
	let count = ref 0 in
	let write (nbits,value) =
		if nbits < 0 then raise (Invalid_argument "write bits");
		if nbits + !count >= 32 then raise (Overflow "write bits");
		data := (!data lsl nbits) lor (value land ((1 lsl nbits)-1));
		count := !count + nbits;
		while !count >= 8 do
			count := !count - 8;
			write_byte ch (!data asr !count)
		done
	in
	let flush_bits() =
		if !count > 0 then write (8 - !count,0)
	in
	create_out
		~write:(fun b -> if b then write (1,1) else write (1,0))
		~nwrite:write
		~pos:(fun () -> pos_out ch * 8 + !count)
		~flush:(fun () -> flush_bits(); flush ch)
		~close:(fun () -> flush_bits(); close_out ch)
