(* 
 * IO - Abstract input/ouput
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

type ('a,'b) input = {
	mutable in_read : unit -> 'a;
	mutable in_nread : int -> 'b;
	mutable in_available : unit -> int option;
	mutable in_close : unit -> unit;
}

type ('a,'b,'c) output = {
	mutable out_write : 'a -> unit;
	mutable out_nwrite : 'b -> unit;
	mutable out_close : unit -> 'c;
	mutable out_flush : unit -> unit;
}

exception No_more_input
exception Input_closed
exception Output_closed

(* -------------------------------------------------------------- *)
(* API *)

let default_available = (fun () -> None)
let default_close = (fun () -> ())

let create_in ~read ~nread ~available ~close =
	{
		in_read = read;
		in_nread = nread;
		in_available = available;
		in_close = close;
	}

let create_out ~write ~nwrite ~flush ~close =
	{
		out_write = write;
		out_nwrite = nwrite;
		out_close = close;
		out_flush = flush;
	}

let read i = i.in_read()
let nread i n = 
	if n < 0 then raise (Invalid_argument "IO.nread");
	i.in_nread n

let available i = i.in_available()
let close_in i = 
	let f _ = raise Input_closed in
	i.in_close();
	i.in_read <- f;
	i.in_nread <- f;
	i.in_available <- (fun () -> Some 0);
	i.in_close <- f

let write o x = o.out_write x
let nwrite o x = o.out_nwrite x

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
				if !pos + n > len then raise No_more_input;
				let s = String.sub s !pos n in
				pos := !pos + n;
				s
			end;
		);
		in_available = (fun () ->
			Some (len - !pos)
		);
		in_close = (fun () -> ());
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
			let s = String.create n in
			try
				really_input ch s 0 n;
				s
			with
				End_of_file -> raise No_more_input
		);
		in_available = (fun () -> None);
		in_close = (fun () -> Pervasives.close_in ch);
	}

let output_channel ch =
	{
		out_write = (fun c -> output_char ch c);
		out_nwrite = (fun s -> Pervasives.output_string ch s);
		out_close = (fun () -> Pervasives.close_out ch);
		out_flush = (fun () -> Pervasives.flush ch);
	}

let input_enum e =
	{
		in_read = (fun () ->
			match Enum.get e with
			| None -> raise No_more_input
			| Some x -> x
		);
		in_nread = (fun n ->
			if n = 0 then
				Enum.empty()
			else
				let pos = ref 0 in
				let elts = DynArray.make n in
				try
					ignore(Enum.find (fun x -> DynArray.unsafe_set elts !pos x; incr pos; !pos = n) e);
					DynArray.enum elts
				with
					Not_found -> raise No_more_input
		);
		in_available = (fun () -> if Enum.fast_count e then Some (Enum.count e) else None);
		in_close = (fun () -> ());
	}

let output_enum() =
	let elts = DynArray.create() in
	{
		out_write = (fun x ->
			DynArray.add elts x
		);
		out_nwrite = (fun e ->
			Enum.iter (DynArray.add elts)  e
		);
		out_close = (fun () ->
			DynArray.enum elts
		);
		out_flush = (fun () -> ());
	}

(* -------------------------------------------------------------- *)
