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

(** A lazy implementation of abstracts enumerators *)

(** {6 Types} *)

type 'a t
(** The type of enumerations *)

exception No_more_elements

(** {6 Eager operations} *)

val make : next:(unit -> 'a) -> count:(unit -> int) -> clone:(unit -> 'a t) -> 'a t

val from : (unit -> 'a) -> 'a t

val init : int -> (int -> 'a) -> 'a t

val iter : ('a -> unit) -> 'a t -> unit

val iteri : (int -> 'a -> unit) -> 'a t -> unit

val iter2 : ('a -> 'b -> unit) -> 'a t -> 'b t -> unit

val iter2i : ( int -> 'a -> 'b -> unit) -> 'a t -> 'b t -> unit

val fold : ('a -> 'b -> 'b) -> 'b -> 'a t -> 'b

val foldi : (int -> 'a -> 'b -> 'b) -> 'b -> 'a t -> 'b

val fold2 : ('a -> 'b -> 'c -> 'c) -> 'c -> 'a t -> 'b t -> 'c

val fold2i : (int -> 'a -> 'b -> 'c -> 'c) -> 'c -> 'a t -> 'b t -> 'c

val find : ('a -> bool) -> 'a t -> 'a
(** [find f x] can be used several times since it consumes the enumeration.
    Raises [Not_found] if the predicate [f] is not true for any value in
    the enumeration.
*)

val force : 'a t -> unit

val clone : 'a t -> 'a t

val empty : 'a t -> bool

val peek : 'a t -> 'a option

val get : 'a t -> 'a option

(** {6 Lazy operations}

    All lazy operations run in O(1) time
*)


val map : ('a -> 'b) -> 'a t -> 'b t

val mapi : (int -> 'a -> 'b) -> 'a t -> 'b t

val map2 : ('a -> 'b -> 'c ) -> 'a t -> 'b t -> 'c t

val map2i : (int -> 'a -> 'b -> 'c ) -> 'a t -> 'b t -> 'c t

val filter : ('a -> bool) -> 'a t -> 'a t

val filter_map : ('a -> 'b option) -> 'a t -> 'b t

val append : 'a t -> 'a t -> 'a t

val concat : 'a t t -> 'a t

val count : 'a t -> int
(** Depending of the underlaying structure that is implementating the Enum
    functions, the count operation can be costly, and sometimes will need
    a intermediate list to be built and all operations applied. Use it with
    care. *)

val fast_count : 'a t -> bool
(** For users worried about the speed of count, theses can call the fast_count
    function that will give an hint about count implementation. Basicly, if
    the enum has been created with [make] or [init] if [force] has been called
    on it, then fast_count will return true. *)
