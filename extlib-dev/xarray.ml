
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

type 'a t = { 
    resize: int -> int -> int ; 
    null : 'a ; 
    mutable length : int ; 
    mutable arr : 'a array 
}

let length xarr = xarr.length

let rec exponential_resizer curr length =
    if curr < length then begin
        if curr < (Sys.max_array_length/2) then
            exponential_resizer (curr * 2) length
        else
            Sys.max_array_length
    end else if ((curr/4) > length) && (curr > 8) then
        exponential_resizer (curr / 2) length
    else
        curr


let step_resizer step =
	if step <= 0 then invalid_arg "Xarray.step_resizer";
	(fun curr length ->
		if step <= 0 then
			assert false
		else if (curr < length) || (length < (curr - step)) then
		   (length + step - (length mod step))
		else
			curr)

let newlength xarr length =
    let oldsize = Array.length xarr.arr in
    let newsize = xarr.resize oldsize length in
    if newsize > oldsize then begin
        let newarr = Array.make newsize xarr.null in
        Array.blit xarr.arr 0 newarr 0 oldsize ;
        xarr.arr <- newarr;
    end else if newsize < oldsize then begin
        let newarr = Array.sub xarr.arr 0 newsize in
        xarr.arr <- newarr;
	end;
    xarr.length <- length


let make ?(resizer = exponential_resizer) initsize nullval = 
    if initsize < 0 then
        invalid_arg "Xarray.make"
    else if initsize = 0 then
        { resize = resizer; length = 0; null = nullval; arr = Array.make 1 nullval }
    else 
        { resize = resizer; length = 0; null = nullval; arr = Array.make initsize nullval }


let init ?(resizer = exponential_resizer) initsize initlength nullval f =
    if (initsize < 0) || (initlength < 0) || (initsize < initlength) then
        invalid_arg "Xarray.init"
    else if initsize = 0 then
        { resize = resizer; length = 0; null = nullval; arr = Array.make 1 nullval }
    else 
        let retarr = Array.make initsize nullval in begin
            for i = 0 to (initlength-1) do
                retarr.(i) <- (f i)
            done;
            { resize = resizer; length = initlength; null = nullval; arr = retarr }
        end


let get xarr idx = 
    if (idx < 0) || (idx >= xarr.length) then
        invalid_arg "Xarray.get"
    else
        xarr.arr.(idx)


let last xarr = 
    if xarr.length = 0 then
        raise (Failure "Xarray.last")
    else
        xarr.arr.(xarr.length - 1)


let set xarr idx v =
   if (idx >= 0) && (idx < xarr.length) then
       xarr.arr.(idx) <- v
   else if idx = xarr.length then begin
       newlength xarr (xarr.length + 1);
       xarr.arr.(idx) <- v
   end else
       invalid_arg "Xarray.set"


let insert xarr idx v =
     if (idx < 0) || (idx > xarr.length) then
        invalid_arg "Xarray.insert"
     else
        newlength xarr (xarr.length + 1);
        if idx < (xarr.length - 1) then
            Array.blit xarr.arr idx xarr.arr (idx+1) (xarr.length - idx - 1);
        xarr.arr.(idx) <- v


let add xarr v =
    newlength xarr (xarr.length + 1);
    xarr.arr.(xarr.length - 1) <- v


let append dst src =
    let oldlength = dst.length in
    newlength dst (oldlength + src.length);
    Array.blit src.arr 0 dst.arr oldlength src.length;
    dst

let delete xarr idx =
    if (idx < 0) || (idx >= xarr.length) then
        invalid_arg "Xarray.delete"
    else begin
        if (idx < (xarr.length - 1)) then
            Array.blit xarr.arr (idx+1) xarr.arr idx (xarr.length - idx - 1);
        xarr.arr.(xarr.length - 1) <- xarr.null;
        newlength xarr (xarr.length - 1)
    end


let delete_last xarr = 
    if xarr.length < 1 then
        invalid_arg "Xarray.delete_last"
    else
        xarr.arr.(xarr.length - 1) <- xarr.null;
        newlength xarr (xarr.length - 1)

 
let rec blit src srcidx dst dstidx len =
    if (srcidx < 0) || (dstidx < 0) || (len < 1) 
        || (dstidx > dst.length) || (srcidx > (src.length - len)) then
        invalid_arg "Xarray.blit"
    else begin
        if (dstidx > (dst.length - len)) then
            newlength dst (dstidx + len);
        Array.blit src.arr srcidx dst.arr dstidx len
    end


let to_list xarr = 
    let rec loop idx accum =
        if (idx < 0) then accum
        else loop (idx - 1) (xarr.arr.(idx) :: accum)
    in
    loop (xarr.length - 1) []


let to_array xarr =
    Array.sub xarr.arr 0 xarr.length


let of_list ?(resizer = exponential_resizer) nullval lst =
    let rec f arr idx lst = 
        match lst with
        | h :: t ->
			arr.(idx) <- h;
			f arr (idx + 1) t
        | [] -> ()
    in
    let xsize = List.length lst in
    if xsize = 0 then
        { resize = resizer; length = 0; null = nullval; 
          arr = Array.make 1 nullval }
    else
        let retval = { resize = resizer; length = xsize; null = nullval; 
                       arr = Array.make xsize nullval } in
        f retval.arr 0 lst;
		retval

let of_array ?(resizer = exponential_resizer) nullval arr =
    let xsize = Array.length arr in
    if xsize = 0 then
        { resize = resizer; length = 0; null = nullval; 
          arr = Array.make 1 nullval }
    else
        { resize = resizer; length = xsize; null = nullval; 
          arr = (Array.copy arr) }

let copy ?resizer src =
    { resize = (
          match resizer with
		  | None -> src.resize
		  | Some f -> f
      );
      length = src.length;
      null = src.null;
      arr = Array.copy src.arr
    }


let sub ?resizer src start len =
    if (start < 0) || (len < 0) || (start >= (src.length - len)) then
        invalid_arg "Xarray.sub"
    else
    let r = (match resizer with None -> src.resize | Some f -> f) in
    let newsize = r (Array.length src.arr) len in
    { resize = r; length = len; null = src.null; 
      arr = Array.sub src.arr start len }


let iter f xarr =
    for i = 0 to (xarr.length - 1) do
        f xarr.arr.(i)
    done


let iteri f xarr =
    for i = 0 to (xarr.length - 1) do
        f i xarr.arr.(i)
    done


let map ?resizer f dstnull src =
    let dst = { resize = (
                    match resizer with
					| None -> src.resize
					| Some f -> f
                );
                length = src.length; 
                null = dstnull; 
                arr = Array.make (Array.length src.arr) dstnull } in
    for i = 0 to (src.length - 1) do
        dst.arr.(i) <- f src.arr.(i)
    done ;
    dst


let mapi ?resizer f dstnull src =
    let dst = { resize = (
                    match resizer with
					| None -> src.resize
					| Some f -> f
                );
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
        if (!idxref >= xarr.length) || (!lenref <= 0) then
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


let of_enum ?(resizer = exponential_resizer) nullval e =
    let c = Enum.count e in
	let retval = Array.make (resizer 1 c) nullval in
    Enum.iteri (fun i x -> (retval.(i) <- x)) e;
    { resize = resizer; null = nullval; length = c; arr = retval }


let insert_enum xarr idx e =
    if (idx < 0) || (idx > xarr.length) then
        invalid_arg "Xarray.insert_enum"
    else
    let c = Enum.count e in
	let oldlen = xarr.length in
    newlength xarr (c + xarr.length);
    if idx < oldlen then
		Array.blit xarr.arr idx xarr.arr (idx + c) (oldlen - idx);
    Enum.iteri (fun i x -> (xarr.arr.(i+idx) <- x)) e

let set_enum xarr idx e =
    if (idx < 0) || (idx > xarr.length) then
        invalid_arg "Xarray.set_enum"
    else
    let c = Enum.count e in
    if c <= 0 then
        Enum.iteri (fun i x -> (set xarr (i+idx) x)) e
    else
        let max = idx + c in
        if max > xarr.length then newlength xarr max;
        Enum.iteri (fun i x -> (xarr.arr.(i+idx) <- x)) e