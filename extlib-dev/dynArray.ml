(*
 * DynArray - dynamic Ocaml arrays
 * Copyright (C) 2003 Brian Hurt (bhurt@spnz.org)
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

type resizer_t = currslots:int -> oldlength:int -> newlength:int -> int

type 'a t = { 
	mutable arr : 'a array;
	mutable length : int; 
	mutable resize: resizer_t; 
	null : 'a; 
}

exception Invalid_arg of int * string * string

let invalid_arg n f p = raise (Invalid_arg (n,f,p))

let length darr = darr.length

let exponential_resizer ~currslots ~oldlength ~newlength =
	let rec doubler x =
		if x > newlength then x
		else if x >= (Sys.max_array_length/2) then Sys.max_array_length
		else doubler (x * 2)
	in
	let rec halfer x =
		if x < 8 || (x / 4) < newlength then x
		else halfer (x/2)
	in
	if currslots < newlength then
		doubler currslots
	else 
		halfer currslots

let step_resizer step =
	if step <= 0 then invalid_arg step "step_resizer" "step";
	(fun ~currslots ~oldlength ~newlength ->
		if currslots < newlength || newlength < (currslots - step) 
		then
		   (newlength + step - (newlength mod step))
		else
			currslots)

let conservative_exponential_resizer ~currslots ~oldlength ~newlength =
	let rec doubler x =
		if x > newlength then x
		else if x >= (Sys.max_array_length/2) then Sys.max_array_length
		else doubler (x * 2)
	in
	let rec halfer x =
		if x < 8 || (x / 4) < newlength then x
		else halfer (x/2)
	in
	if currslots < newlength then
		doubler currslots
	else if oldlength < newlength then
		halfer currslots
	else
		currslots

let default_resizer = exponential_resizer

let changelength darr step =
	let t = darr.length + step in
	let newlength = if t < 0 then 0 else t in
	let oldsize = Array.length darr.arr in
	let r = darr.resize 
				~currslots:oldsize
				~oldlength:darr.length
				~newlength:newlength
	in
	(* We require the size to be at least large enough to hold the number
	 * of elements we know we need!
	 *)
	let newsize = if r < newlength then newlength else r in
	if newsize > oldsize then begin
		let newarr = Array.make newsize darr.null in
		Array.blit darr.arr 0 newarr 0 oldsize ;
		darr.arr <- newarr;
	end else if newsize < oldsize then begin
		let newarr = Array.sub darr.arr 0 newsize in
		darr.arr <- newarr;
	end;
	darr.length <- newlength

let make initsize nullval = 
	if initsize < 0 then invalid_arg initsize "make" "size";
	{ resize = default_resizer; length = 0; null = nullval; 
	  arr = Array.make initsize nullval }

let init initsize initlength nullval f =
	if initsize < 0 then invalid_arg initsize "init" "size";
	if initlength < 0 || initsize < initlength then
		invalid_arg initlength "init" "length";
	let retarr = Array.make initsize nullval in
	for i = 0 to initlength-1 do
		retarr.(i) <- (f i)
	done;
	{ resize = default_resizer; length = initlength; null = nullval; 
	  arr = retarr }

let set_resizer darr resizer =
	darr.resize <- resizer

let get_resizer darr =
	darr.resize

let empty darr =
	darr.length = 0

let get darr idx = 
	if idx < 0 || idx >= darr.length then invalid_arg idx "get" "index";
	darr.arr.(idx)

let last darr = 
	if darr.length = 0 then invalid_arg 0 "last" "<array length is 0>";
	darr.arr.(darr.length - 1)

let set darr idx v =
	if idx >= 0 && idx < darr.length then
		darr.arr.(idx) <- v
	else if idx = darr.length then begin
		changelength darr 1;
		darr.arr.(idx) <- v
	end else
		invalid_arg idx "set" "index"

let insert darr idx v =
	if idx < 0 || idx > darr.length then
		invalid_arg idx "insert" "index";
	changelength darr 1;
	if idx < (darr.length - 1) then
		Array.blit darr.arr idx darr.arr (idx+1) (darr.length - idx - 1);
	darr.arr.(idx) <- v

let add darr v =
	changelength darr 1;
	darr.arr.(darr.length - 1) <- v

let append dst src =
	let oldlength = dst.length in
	changelength dst src.length;
	Array.blit src.arr 0 dst.arr oldlength src.length;
	dst

let delete darr idx =
	if idx < 0 || idx >= darr.length then invalid_arg idx "delete" "index";
	if idx < (darr.length - 1) then
		Array.blit darr.arr (idx+1) darr.arr idx (darr.length - idx - 1);
	darr.arr.(darr.length - 1) <- darr.null;
	changelength darr (-1)

let delete_last darr = 
	if darr.length < 1 then invalid_arg 0 "delete_last" "<array length is 0>";
	darr.arr.(darr.length - 1) <- darr.null;
	changelength darr (-1)
 
let rec blit src srcidx dst dstidx len =
	if srcidx < 0 || srcidx > (src.length - len) then 
		invalid_arg srcidx "blit" "sou rce index";
	if len < 0 then invalid_arg len "blit" "length";
	if dstidx < 0 || dstidx > dst.length then
		invalid_arg dstidx "blit" "dest index";
	if dstidx > (dst.length - len) then
		changelength dst (dstidx + len - dst.length);
	Array.blit src.arr srcidx dst.arr dstidx len

let to_list darr = 
	let rec loop idx accum =
		if idx < 0 then accum
		else loop (idx - 1) (darr.arr.(idx) :: accum)
	in
	loop (darr.length - 1) []

let to_array darr =
	Array.sub darr.arr 0 darr.length

let of_list nullval lst =
	let rec f arr idx lst = 
		match lst with
		| h :: t ->
			arr.(idx) <- h;
			f arr (idx + 1) t
		| [] -> ()
	in
	let xsize = List.length lst in
	let retval = { resize = default_resizer; length = xsize; null = nullval; 
				   arr = Array.make xsize nullval } in
	f retval.arr 0 lst;
	retval

let of_array nullval arr =
	{
		resize = default_resizer;
		length = Array.length arr;
		null = nullval; 
		arr = Array.make 0 nullval;
	}

let copy src =
	{
		resize = src.resize;
		length = src.length;
		null = src.null;
		arr = Array.sub src.arr 0 src.length;
	}

let sub src start len =
	if start < 0 || start >= (src.length - len) then
		invalid_arg start "sub" "start";
	if len < 0 || (len+start) > src.length then
		invalid_arg len "sub" "length";
	let newsize = src.resize
					~currslots:0 
					~oldlength:0
					~newlength:len 
	in
	{ resize = src.resize; length = len; null = src.null; 
	  arr = Array.sub src.arr start len }

let iter f darr =
	for i = 0 to (darr.length - 1) do
		f darr.arr.(i)
	done

let iteri f darr =
	for i = 0 to (darr.length - 1) do
		f i darr.arr.(i)
	done

let map f dstnull src =
	let dst = { resize = src.resize;
				length = src.length; 
				null = dstnull; 
				arr = Array.make (Array.length src.arr) dstnull } in
	for i = 0 to (src.length - 1) do
		dst.arr.(i) <- f src.arr.(i)
	done ;
	dst

let mapi f dstnull src =
	let dst = { resize = src.resize;
				length = src.length; 
				null = dstnull; 
				arr = Array.make (Array.length src.arr) dstnull } in
	for i = 0 to (src.length - 1) do
		dst.arr.(i) <- f i src.arr.(i)
	done ;
	dst

let fold_left f x a =
	let rec loop idx x =
		if idx >= a.length then x
		else loop (idx + 1) (f x a.arr.(idx))
	in
	loop 0 x

let fold_right f a x =
	let rec loop idx x =
		if idx < 0 then x
		else loop (idx - 1) (f a.arr.(idx) x)
	in
	loop (a.length - 1) x

let enum darr =
	let idxref = ref 0 in
	let next () =
		if !idxref >= darr.length then
			raise Enum.No_more_elements
		else
			let retval = darr.arr.( !idxref ) in
			incr idxref;
			retval
	and count () =
		if !idxref >= darr.length then 0
		else darr.length - !idxref
	in
	Enum.make ~next:next ~count:count

let sub_enum darr initidx len =
	let idxref = ref 0
	and lenref = ref len
	in
	let next () =
		if !idxref >= darr.length || !lenref <= 0 then
			raise Enum.No_more_elements
		else
			let retval = darr.arr.( !idxref ) in
			incr idxref;
			decr lenref;
			retval
	and count () =
		if !idxref >= darr.length then 0
		else if !idxref + !lenref - 1 >= darr.length then 
			darr.length - !idxref
		else
		   !lenref
	in
	Enum.make ~next:next ~count:count

let of_enum nullval e =
	let c = Enum.count e in
	let retval = Array.make c nullval in
	Enum.iteri (fun i x -> (retval.(i) <- x)) e;
	{ resize = default_resizer; null = nullval; length = c; arr = retval }

let insert_enum darr idx e =
	if idx < 0 || idx > darr.length then
		invalid_arg idx "insert_enum" "index";
	let c = Enum.count e in
	let oldlen = darr.length in
	changelength darr c ;
	if idx < oldlen then
		Array.blit darr.arr idx darr.arr (idx + c) (oldlen - idx);
	Enum.iteri (fun i x -> (darr.arr.(i+idx) <- x)) e

let set_enum darr idx e =
	if idx < 0 || idx > darr.length then invalid_arg idx "set_enum" "index";
	let c = Enum.count e in
	if c <= 0 then
		Enum.iteri (fun i x -> (set darr (i+idx) x)) e
	else
		let max = idx + c in
		if max > darr.length then changelength darr (max - darr.length);
		Enum.iteri (fun i x -> (darr.arr.(i+idx) <- x)) e

let rev_enum darr =
	let idxref = ref (darr.length - 1) in
	let next () =
		if !idxref < 0 then
			raise Enum.No_more_elements
		else
			let retval = darr.arr.( !idxref ) in
			decr idxref;
			retval
	and count () =
		if !idxref < 0 then 0
		else 1 + !idxref
	in
	Enum.make ~next:next ~count:count

let sub_rev_enum darr initidx len =
	let idxref = ref (len - 1)
	in
	let next () =
		if !idxref < 0 then
			raise Enum.No_more_elements;
		if !idxref >= (darr.length - initidx) then
			invalid_arg !idxref "sub_rev_enum" "index";
		let retval = darr.arr.( initidx + !idxref ) in
		decr idxref;
		retval
	and count () =
		if !idxref < 0 then 0
		else 1 + !idxref
	in
	Enum.make ~next:next ~count:count

let of_rev_enum nullval e =
	let c = Enum.count e in
	let retval = Array.make c nullval 
	in
	Enum.iteri (fun i x -> (retval.(c - 1 - i) <- x)) e;
	{ resize = default_resizer; null = nullval; length = c; arr = retval }

let insert_rev_enum darr idx e =
	if idx < 0 || idx > darr.length then invalid_arg idx "insert_enum" "index";
	let c = Enum.count e in
	let oldlen = darr.length in
	changelength darr c;
	if idx < oldlen then
		Array.blit darr.arr idx darr.arr (idx + c) (oldlen - idx);
	Enum.iteri (fun i x -> (darr.arr.(idx+c-1-i) <- x)) e

let set_rev_enum darr idx e =
	if idx < 0 || idx > darr.length then invalid_arg idx "set_enum" "index";
	let c = Enum.count e in
	let max = idx + c in
	if max > darr.length then changelength darr (max - darr.length);
	Enum.iteri (fun i x -> (darr.arr.(idx+c-1-i) <- x)) e
