(* Enum, a lazy implementation of abstracts enumerators
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
 *
 *)

type 'a t = {
	mutable count : unit -> int;
	mutable next : unit -> 'a;
}

exception No_more_elements (* raised by 'next' functions, does NOT goes outside the API *)

let _dummy () = assert false

let make ~next ~count =
	{
		count = count;
		next = next;
	}

let count t =
	t.count()

let has_more t =
	t.count() > 0

let iter f t =
	let rec loop () =
		f (t.next());
		loop();
	in
	try
		loop();
	with
		No_more_elements -> ()

let fold f init t =
	let ret = ref init in
	let rec loop accu =
		loop (f (try t.next() with No_more_elements as e -> ret := accu; raise e) accu)
	in
	try
		loop init
	with
		No_more_elements -> !ret

let find f t =
	let rec loop () =
		let x = t.next() in
		if f x then x else loop()
	in
	try
		loop()
	with
		No_more_elements -> raise Not_found

let map f t =
	{
		count = t.count;
		next = (fun () -> f (t.next()));
	}

let force t =
	let count = ref 1 in
	let rec loop dst =
		let x = [t.next()] in
		incr count;
		Obj.set_field (Obj.repr dst) 1 (Obj.repr x);
		loop x
	in
	try
		let x = [t.next()] in
		(try loop x with No_more_elements -> ());
		let enum = ref x in 
		{
			count = (fun () -> !count);
			next = (fun () ->
				decr count;
				match !enum with
				| [] -> raise No_more_elements
				| h :: t -> enum := t; h);
		}
	with
		No_more_elements ->
			{
				count = (fun () -> 0);
				next = (fun () -> raise No_more_elements);
			}

let filter f t =
	let rec filter_next() =
		let x = t.next() in
		if f x then x else filter_next()
	in
	let tf = {
		count = _dummy;
		next = filter_next;
	} in
	tf.count <- (fun () ->
		let tforced = force tf in
		tf.count <- tforced.count;
		tf.next <- tforced.next;
		tf.count());
	tf

let append ta tb = 
	let t = {
		count = (fun () -> ta.count() + tb.count());
		next = _dummy;
	} in
	t.next <- (fun () ->
		try
			ta.next()
		with
			No_more_elements ->
				t.next <- tb.next;
				t.next()
	);
	t

let concat t =
	let tc = {
		count = (fun () -> fold (fun tt acc -> tt.count() + acc) 0 t);
		next = _dummy;
	} in
	let rec concat_next() =
		let tn = t.next() in
		tc.next <- (fun () ->
			try
				tn.next()
			with
				No_more_elements ->
					concat_next());
		tc.next()
	in
	tc.next <- concat_next;
	tc