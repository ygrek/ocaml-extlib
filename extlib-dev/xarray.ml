
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


type 'a xarray_t = { 
    resize: int -> int -> int ; 
    null : 'a ; 
    mutable used : int ; 
    mutable arr : 'a array 
};;

let used xarr = xarr.used;;

let rec exponential_resizer curr used =
    if (curr < used) then
        if (curr < (Sys.max_array_length/2)) then
            exponential_resizer (curr * 2) used
        else
            Sys.max_array_length
    else if (((curr/4) > used) && (curr > 8)) then
        exponential_resizer (curr / 2) used
    else
        curr
;;

let step_resizer step curr used =
    if (step <= 0) then
        ( let _ = Invalid_argument "Xarray.step_resize" in 0)
    else if ((curr < used) || (used < (curr - step))) then
       (used + step - (used mod step))
    else
        curr
;;

let newused xarr used =
    let oldlen = Array.length xarr.arr in
    let newlen = xarr.resize oldlen used in
    if (newlen > oldlen) then
        let newarr = Array.make newlen xarr.null in (
            Array.blit xarr.arr 0 newarr 0 oldlen ;
            xarr.arr <- newarr
        )
    else if (newlen < oldlen) then
        let newarr = Array.sub xarr.arr 0 newlen in
        xarr.arr <- newarr
    else ();
    xarr.used <- used
;;

let make ?(resizer = exponential_resizer) initlen nullval = 
    if (initlen < 0) then
        invalid_arg "Xarray.make"
    else if (initlen == 0) then
        { resize = resizer; used = 0; null = nullval; arr = Array.make 1 nullval }
    else 
        { resize = resizer; used = 0; null = nullval; arr = Array.make initlen nullval }
;;

let init ?(resizer = exponential_resizer) initlen initused nullval f =
    if ((initlen < 0) || (initused < 0) || (initlen < initused)) then
        invalid_arg "Xarray.init"
    else if (initlen == 0) then
        { resize = resizer; used = 0; null = nullval; arr = Array.make 1 nullval }
    else 
        let retarr = Array.make initlen nullval in (
            for i = 0 to (initused-1) do
                retarr.(i) <- (f i)
            done;
            { resize = resizer; used = initused; null = nullval; arr = retarr }
        )
;;

let get xarr idx = 
    if ((idx < 0) || (idx >= xarr.used)) then
        invalid_arg "Xarray.get"
    else
        xarr.arr.(idx)
;;

let last xarr = 
    if (xarr.used == 0) then
        raise (Failure "Xarray.last")
    else
        xarr.arr.(xarr.used - 1)
;;

let set xarr idx v =
   if ((idx >= 0) && (idx < xarr.used)) then
       xarr.arr.(idx) <- v
   else if (idx == xarr.used) then (
       newused xarr (xarr.used + 1);
       xarr.arr.(idx) <- v
   ) else
       invalid_arg "Xarray.set"
;;

let insert xarr idx v =
     if ((idx < 0) || (idx > xarr.used)) then
        invalid_arg "Xarray.insert"
     else
        newused xarr (xarr.used + 1);
        if (idx < (xarr.used - 1)) then
            Array.blit xarr.arr idx xarr.arr (idx+1) (xarr.used - idx - 1)
        else ();
        xarr.arr.(idx) <- v
;;

let append_element xarr v =
    newused xarr (xarr.used + 1);
    xarr.arr.(xarr.used - 1) <- v
;;

let append dst src =
    let oldused = dst.used in (
        newused dst (oldused + src.used);
        Array.blit src.arr 0 dst.arr oldused src.used
    );
    dst
;;

let delete xarr idx =
    if ((idx < 0) || (idx >= xarr.used)) then
        invalid_arg "Xarray.delete"
    else (
        if (idx < (xarr.used - 1)) then
            Array.blit xarr.arr (idx+1) xarr.arr idx (xarr.used - idx - 1)
        else ();
        xarr.arr.(xarr.used - 1) <- xarr.null;
        newused xarr (xarr.used - 1)
    )
;;

let delete_last xarr = 
    if (xarr.used < 1) then
        invalid_arg "Xarray.delete_last"
    else
        xarr.arr.(xarr.used - 1) <- xarr.null;
        newused xarr (xarr.used - 1)
;;
 
let set_length xarr len =
    if (len < xarr.used) then (
        Array.fill xarr.arr len (xarr.used - len + 1) xarr.null ;
    ) else (
        xarr.used <- len
    );
    let oldlen = Array.length xarr.arr in
    if (len != oldlen) then
        let newarr = Array.make len xarr.null in (
            Array.blit xarr.arr 0 newarr 0 (min oldlen len) ;
            xarr.arr <- newarr
        )
    else ();
;;

let rec blit src srcidx dst dstidx len =
    if ((srcidx < 0) || (dstidx < 0) || (len < 1) 
        || (dstidx > dst.used) || (srcidx > (src.used - len))) then
        invalid_arg "Xarray.blit"
    else (
        if (dstidx > (dst.used - len)) then
            newused dst (dstidx + len)
        else ();
        Array.blit src.arr srcidx dst.arr dstidx len
    )
;;

let to_list xarr = 
    let rec loop idx accum =
        if (idx < 0) then accum
        else loop (idx - 1) (xarr.arr.(idx) :: accum)
    in
    loop (xarr.used - 1) []
;;

let to_array xarr =
    Array.sub xarr.arr 0 xarr.used
;;

let of_list ?(resizer = exponential_resizer) nullval lst =
    let rec f arr idx lst = 
        match lst with
            (h :: t) -> ( arr.(idx) <- h ; f arr (idx + 1) t )
            | [] -> ()
    in
    let xlen = List.length lst in
    if (xlen == 0) then
        { resize = resizer; used = 0; null = nullval; 
          arr = Array.make 1 nullval }
    else  (
        let retval = { resize = resizer; used = xlen; null = nullval; 
                       arr = Array.make xlen nullval } in
        f retval.arr 0 lst ; retval
    )
;;

let of_array ?(resizer = exponential_resizer) nullval arr =
    let xlen = Array.length arr in
    if (xlen == 0) then
        { resize = resizer; used = 0; null = nullval; 
          arr = Array.make 1 nullval }
    else (
        { resize = resizer; used = xlen; null = nullval; 
          arr = (Array.copy arr) }
    )
;;

let invalid_resizer: int -> int -> int = fun _ -> fun _ -> assert false; 0;;

let copy ?(resizer = invalid_resizer) src =
    { resize = (
          if (resizer == invalid_resizer) then
              (* used the same resizing function as before *)
              src.resize
          else
              resizer
      );
      used = src.used;
      null = src.null;
      arr = Array.copy src.arr
    }
;;

let sub ?(resizer = invalid_resizer) src start len =
    if ((start < 0) || (len < 0) || (start >= (src.used - len))) then
        invalid_arg "Xarray.sub"
    else
    let r = if (resizer == invalid_resizer) then src.resize else resizer in
    let newlen = r (Array.length src.arr) len in
    { resize = r; used = len; null = src.null; 
      arr = Array.sub src.arr start len }
;;

let iter f xarr =
    for i = 0 to (xarr.used - 1) do
        f xarr.arr.(i)
    done
;;

let iteri f xarr =
    for i = 0 to (xarr.used - 1) do
        f i xarr.arr.(i)
    done
;;

let map ?(resizer = invalid_resizer) f dstnull src =
    let dst = { resize = (
                    if (resizer == invalid_resizer) then
                        src.resize
                    else
                        resizer
                );
                used = src.used; 
                null = dstnull; 
                arr = Array.make (Array.length src.arr) dstnull } in
    for i = 0 to (src.used - 1) do
        dst.arr.(i) <- f src.arr.(i)
    done ;
    dst
;;

let mapi ?(resizer = invalid_resizer) f dstnull src =
    let dst = { resize = (
                    if (resizer == invalid_resizer) then
                        src.resize
                    else
                        resizer
                );
                used = src.used; 
                null = dstnull; 
                arr = Array.make (Array.length src.arr) dstnull } in
    for i = 0 to (src.used - 1) do
        dst.arr.(i) <- f i src.arr.(i)
    done ;
    dst
;;

let fold_left f x a =
    let rec loop idx x =
        if (idx >= a.used) then x
        else loop (idx + 1) (f x a.arr.(idx))
    in
    loop 0 x
;;

let fold_right f a x =
    let rec loop idx x =
        if (idx < 0) then x
        else loop (idx - 1) (f a.arr.(idx) x)
    in
    loop (a.used - 1) x
;;

