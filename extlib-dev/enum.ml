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

let iter f t =
	let rec loop () =
		f (t.next());
		loop();
	in
	try
		loop();
	with
		No_more_elements -> ()

let iteri f t =
	let rec loop idx =
		f idx (t.next());
		loop (idx+1);
	in
	try
		loop 0;
	with
		No_more_elements -> ()

let iter2 f t u =
	let rec loop idx =
		f (t.next()) (u.next());
		loop (idx + 1)
	in
	try
		loop 0
	with
		No_more_elements -> ()

let iter2i f t u =
	let rec loop idx =
		f idx (t.next()) (u.next());
		loop (idx + 1)
	in
	try
		loop 0
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

let foldi f init t =
	let ret = ref init in
	let rec loop idx accu =
		loop (idx + 1) (f idx (try t.next() with No_more_elements as e -> ret := accu; raise e) accu)
	in
	try
		loop 0 init
	with
		No_more_elements -> !ret

let fold2 f init t u =
	let ret = ref init in
	let rec loop accu =
		let a, b = try t.next(), u.next()
				with No_more_elements as e -> ret := accu; raise e
		in
		loop (f a b accu)
	in
	try
		loop init
	with
		No_more_elements -> !ret

let fold2i f init t u =
	let ret = ref init in
	let rec loop idx accu =
		let a, b = try t.next(), u.next()
				with No_more_elements as e -> ret := accu; raise e
		in
		loop (idx + 1) (f idx a b accu)
	in
	try
		loop 0 init
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

let mapi f t =
	let idx = ref 0 in
	{
		count = t.count;
		next = (fun () -> let i = !idx in incr idx; f i (t.next()));
	}

let map2 f t u =
	{
		count = (fun () -> (min (t.count()) (u.count())));
		next = (fun () -> f (t.next()) (u.next()))
	}

let map2i f t u =
	let idx = ref 0 in
	{
		count = (fun () -> (min (t.count()) (u.count())));
		next = (fun () -> let i = !idx in incr idx; f i (t.next()) (u.next()));
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
		t.count <- (fun () -> !count);
		t.next <- (fun () ->
			decr count;
			match !enum with
			| [] -> raise No_more_elements
			| h :: t -> enum := t; h);
	with
		No_more_elements ->
			t.count <- (fun () -> 0);
			t.next <- (fun () -> raise No_more_elements)

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
		force tf;
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

let from f =
	let e = {
		next = f;
		count = _dummy;
	} in
	e.count <- (fun () -> force e; e.count());
	e

let filter_map f t =
    let rec next () =
        match f (t.next()) with
        | None -> next()
        | Some x -> x
    in
    from next

let clone t =
	let cache_t = ref [] in
	let cache_t_count = ref 0 in
	let cache_tc = ref [] in
	let cache_tc_count = ref 0 in
	let fnext = t.next in
	let fcount = t.count in
	let tc = {
		next = (fun () ->
					match !cache_tc with
					| [] ->
						let e = fnext() in
						incr cache_t_count;
						cache_t := e :: !cache_t;
						e
					| h :: t ->
						decr cache_tc_count;
						cache_tc := t;
						h);
		count = (fun () -> fcount() + !cache_tc_count);
	} in
	t.next <- (fun () ->
		match !cache_t with
		| [] ->
			let e = fnext() in
			incr cache_tc_count;
			cache_tc := e :: !cache_tc;
			e
		| h :: t ->
			decr cache_t_count;
			cache_t := t;
			h);
	t.count <- (fun () -> fcount() + !cache_t_count);
	tc
