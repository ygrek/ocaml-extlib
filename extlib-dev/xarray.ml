(*
 * Xarray - resizeable Ocaml arrays
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

let length xarr = xarr.length

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

let changelength xarr step =
	let t = xarr.length + step in
	let newlength = if t < 0 then 0 else t in
	let oldsize = Array.length xarr.arr in
	let r = xarr.resize 
				~currslots:oldsize
				~oldlength:xarr.length
				~newlength:newlength
	in
	(* We require the size to be at least large enough to hold the number
	 * of elements we know we need!
	 *)
	let newsize = if r < newlength then newlength else r in
	if newsize > oldsize then begin
		let newarr = Array.make newsize xarr.null in
		Array.blit xarr.arr 0 newarr 0 oldsize ;
		xarr.arr <- newarr;
	end else if newsize < oldsize then begin
		let newarr = Array.sub xarr.arr 0 newsize in
		xarr.arr <- newarr;
	end;
	xarr.length <- newlength

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

let set_resizer xarr resizer =
	xarr.resize <- resizer

let empty xarr =
	xarr.length = 0

let get xarr idx = 
	if idx < 0 || idx >= xarr.length then invalid_arg idx "get" "index";
	xarr.arr.(idx)

let last xarr = 
	if xarr.length = 0 then invalid_arg 0 "last" "<array length is 0>";
	xarr.arr.(xarr.length - 1)

let set xarr idx v =
	if idx >= 0 && idx < xarr.length then
		xarr.arr.(idx) <- v
	else if idx = xarr.length then begin
		changelength xarr 1;
		xarr.arr.(idx) <- v
	end else
		invalid_arg idx "set" "index"

let insert xarr idx v =
	if idx < 0 || idx > xarr.length then
		invalid_arg idx "insert" "index";
	changelength xarr 1;
	if idx < (xarr.length - 1) then
		Array.blit xarr.arr idx xarr.arr (idx+1) (xarr.length - idx - 1);
	xarr.arr.(idx) <- v

let add xarr v =
	changelength xarr 1;
	xarr.arr.(xarr.length - 1) <- v

let append dst src =
	let oldlength = dst.length in
	changelength dst src.length;
	Array.blit src.arr 0 dst.arr oldlength src.length;
	dst

let delete xarr idx =
	if idx < 0 || idx >= xarr.length then invalid_arg idx "delete" "index";
	if idx < (xarr.length - 1) then
		Array.blit xarr.arr (idx+1) xarr.arr idx (xarr.length - idx - 1);
	xarr.arr.(xarr.length - 1) <- xarr.null;
	changelength xarr (-1)

let delete_last xarr = 
	if xarr.length < 1 then invalid_arg 0 "delete_last" "<array length is 0>";
	xarr.arr.(xarr.length - 1) <- xarr.null;
	changelength xarr (-1)
 
let rec blit src srcidx dst dstidx len =
	if srcidx < 0 || srcidx > (src.length - len) then 
		invalid_arg srcidx "blit" "sou rce index";
	if len < 0 then invalid_arg len "blit" "length";
	if dstidx < 0 || dstidx > dst.length then
		invalid_arg dstidx "blit" "dest index";
	if dstidx > (dst.length - len) then
		changelength dst (dstidx + len - dst.length);
	Array.blit src.arr srcidx dst.arr dstidx len

let to_list xarr = 
	let rec loop idx accum =
		if idx < 0 then accum
		else loop (idx - 1) (xarr.arr.(idx) :: accum)
	in
	loop (xarr.length - 1) []

let to_array xarr =
	Array.sub xarr.arr 0 xarr.length

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

let iter f xarr =
	for i = 0 to (xarr.length - 1) do
		f xarr.arr.(i)
	done

let iteri f xarr =
	for i = 0 to (xarr.length - 1) do
		f i xarr.arr.(i)
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

let enum xarr =
	let idxref = ref 0 in
	let next () =
		if !idxref >= xarr.length then
			raise Enum.No_more_elements
		else
			let retval = xarr.arr.( !idxref ) in
			incr idxref;
			retval
	and count () =
		if !idxref >= xarr.length then 0
		else xarr.length - !idxref
	in
	Enum.make ~next:next ~count:count

let sub_enum xarr initidx len =
	let idxref = ref 0
	and lenref = ref len
	in
	let next () =
		if !idxref >= xarr.length || !lenref <= 0 then
			raise Enum.No_more_elements
		else
			let retval = xarr.arr.( !idxref ) in
			incr idxref;
			decr lenref;
			retval
	and count () =
		if !idxref >= xarr.length then 0
		else if !idxref + !lenref - 1 >= xarr.length then 
			xarr.length - !idxref
		else
		   !lenref
	in
	Enum.make ~next:next ~count:count

let of_enum nullval e =
	let c = Enum.count e in
	let retval = Array.make c nullval in
	Enum.iteri (fun i x -> (retval.(i) <- x)) e;
	{ resize = default_resizer; null = nullval; length = c; arr = retval }

let insert_enum xarr idx e =
	if idx < 0 || idx > xarr.length then
		invalid_arg idx "insert_enum" "index";
	let c = Enum.count e in
	let oldlen = xarr.length in
	changelength xarr c ;
	if idx < oldlen then
		Array.blit xarr.arr idx xarr.arr (idx + c) (oldlen - idx);
	Enum.iteri (fun i x -> (xarr.arr.(i+idx) <- x)) e

let set_enum xarr idx e =
	if idx < 0 || idx > xarr.length then invalid_arg idx "set_enum" "index";
	let c = Enum.count e in
	if c <= 0 then
		Enum.iteri (fun i x -> (set xarr (i+idx) x)) e
	else
		let max = idx + c in
		if max > xarr.length then changelength xarr (max - xarr.length);
		Enum.iteri (fun i x -> (xarr.arr.(i+idx) <- x)) e

let rev_enum xarr =
	let idxref = ref (xarr.length - 1) in
	let next () =
		if !idxref < 0 then
			raise Enum.No_more_elements
		else
			let retval = xarr.arr.( !idxref ) in
			decr idxref;
			retval
	and count () =
		if !idxref < 0 then 0
		else 1 + !idxref
	in
	Enum.make ~next:next ~count:count

let sub_rev_enum xarr initidx len =
	let idxref = ref (len - 1)
	in
	let next () =
		if !idxref < 0 then
			raise Enum.No_more_elements;
		if !idxref >= (xarr.length - initidx) then
			invalid_arg !idxref "sub_rev_enum" "index";
		let retval = xarr.arr.( initidx + !idxref ) in
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

let insert_rev_enum xarr idx e =
	if idx < 0 || idx > xarr.length then invalid_arg idx "insert_enum" "index";
	let c = Enum.count e in
	let oldlen = xarr.length in
	changelength xarr c;
	if idx < oldlen then
		Array.blit xarr.arr idx xarr.arr (idx + c) (oldlen - idx);
	Enum.iteri (fun i x -> (xarr.arr.(idx+c-1-i) <- x)) e

let set_rev_enum xarr idx e =
	if idx < 0 || idx > xarr.length then invalid_arg idx "set_enum" "index";
	let c = Enum.count e in
	let max = idx + c in
	if max > xarr.length then changelength xarr (max - xarr.length);
	Enum.iteri (fun i x -> (xarr.arr.(idx+c-1-i) <- x)) e
