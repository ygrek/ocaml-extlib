(*
 * ExtHashtbl, extra functions over hashtables.
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


module Hashtbl =
  struct

#if OCAML < 412
  external old_hash_param :
    int -> int -> 'a -> int = "caml_hash_univ_param" "noalloc"
#endif

  type ('a, 'b) h_bucketlist =
    | Empty
    | Cons of 'a * 'b * ('a, 'b) h_bucketlist

  type ('a, 'b) h_t = {
    mutable size: int;
    mutable data: ('a, 'b) h_bucketlist array;
    mutable seed: int;
    initial_size: int;
  }

  include Hashtbl

  external h_conv : ('a, 'b) t -> ('a, 'b) h_t = "%identity"
  external h_make : ('a, 'b) h_t -> ('a, 'b) t = "%identity"

  let exists = mem

  let enum h =
    let rec make ipos ibuck idata icount =
      let pos = ref ipos in
      let buck = ref ibuck in
      let hdata = ref idata in
      let hcount = ref icount in
      let force() =
        (** this is a hack in order to keep an O(1) enum constructor **)
        if !hcount = -1 then begin
          hcount := (h_conv h).size;
          hdata := Array.copy (h_conv h).data;
        end;
      in
      let rec next() =
        force();
        match !buck with
        | Empty ->
          if !hcount = 0 then raise Enum.No_more_elements;
          incr pos;
          buck := Array.unsafe_get !hdata !pos;
          next()
        | Cons (k,i,next_buck) ->
          buck := next_buck;
          decr hcount;
          (k,i)
      in
      let count() =
        if !hcount = -1 then (h_conv h).size else !hcount
      in
      let clone() =
        force();
        make !pos !buck !hdata !hcount
      in
      Enum.make ~next ~count ~clone
    in
    make (-1) Empty (Obj.magic()) (-1)

  let keys h =
    Enum.map (fun (k,_) -> k) (enum h)

  let values h =
    Enum.map (fun (_,v) -> v) (enum h)

  let map f h =
    let rec loop = function
      | Empty -> Empty
      | Cons (k,v,next) -> Cons (k,f v,loop next)
    in
    h_make { (h_conv h) with
      data = Array.map loop (h_conv h).data;
    }

  (* copied from stdlib :( *)
  let key_index h key =
    (* compatibility with old hash tables *)
    if Obj.size (Obj.repr h) >= 3
    then (seeded_hash_param 10 100 (h_conv h).seed key) land (Array.length (h_conv h).data - 1)
  #if OCAML >= 412
    else failwith "Old hash function not supported anymore"
  #else
    else (old_hash_param 10 100 key) mod (Array.length (h_conv h).data)
  #endif

  let remove_all h key =
    let hc = h_conv h in
    let rec loop = function
      | Empty -> Empty
      | Cons(k,v,next) ->
        if k = key then begin
          hc.size <- pred hc.size;
          loop next
        end else
          Cons(k,v,loop next)
    in
    let pos = key_index h key in
    Array.unsafe_set hc.data pos (loop (Array.unsafe_get hc.data pos))

  let find_default h key defval =
    let rec loop = function
      | Empty -> defval
      | Cons (k,v,next) ->
        if k = key then v else loop next
    in
    let pos = key_index h key in
    loop (Array.unsafe_get (h_conv h).data pos)

#if OCAML < 405
  let find_opt h key =
    let rec loop = function
      | Empty -> None
      | Cons (k,v,next) ->
        if k = key then Some v else loop next
    in
    let pos = key_index h key in
    loop (Array.unsafe_get (h_conv h).data pos)
#endif

  let find_option = find_opt

  let of_enum e =
    let h = create (if Enum.fast_count e then Enum.count e else 0) in
    Enum.iter (fun (k,v) -> add h k v) e;
    h

  let length h =
    (h_conv h).size

  end
