(*
 * ExtArray - additional and modified functions for arrays.
 * Copyright (C) 2005 Richard W.M. Jones (rich @ annexia.org)
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

(** Additional and modified functions for arrays.

  The OCaml standard library provides a module of array functions.
  This ExtArray module can be used to override the Array module or
  as a standalone module. It provides some additional functions.
*)

module Array :
sig

  type 'a t = 'a array

  (** {6 New functions} *)
  val rev : 'a array -> 'a array
    (** Array reversal. *)

  val rev_in_place : 'a array -> unit
    (** In-place array reversal.  The array argument is updated. *)

  val iter2 : ('a -> 'b -> unit) -> 'a array -> 'b array -> unit
    (** [Array.iter2 f [|a1; ...; an|] [|b1; ...; bn|]] performs
    calls [f a1 b1; ...; f an bn] in that order.

    @raise Invalid_argument if the length of [a1] does not equal the
    length of [a2]. *)

  val map2 : ('a -> 'b -> 'c) -> 'a array -> 'b array -> 'c array
    (** [Array.map2 f [|a1; ...; an|] [|b1; ...; bn|]] creates new array
    [[|f a1 b1; ...; f an bn|]].

    @raise Invalid_argument if the length of [a1] does not equal the
    length of [a2]. *)

  val for_all : ('a -> bool) -> 'a array -> bool
    (** [for_all p [a1; ...; an]] checks if all elements of the array
  satisfy the predicate [p].  That is, it returns
  [ (p a1) && (p a2) && ... && (p an)].
    *)

  val exists : ('a -> bool) -> 'a array -> bool
    (** [exists p [a1; ...; an]] checks if at least one element of
  the array satisfies the predicate [p].  That is, it returns
  [ (p a1) || (p a2) || ... || (p an)].
    *)

  val mem : 'a -> 'a array -> bool
    (** [mem m a] is true if and only if [m] is equal to an element of [a]. *)

  val memq : 'a -> 'a array -> bool
    (** Same as {!Array.mem} but uses physical equality instead of
  structural equality to compare array elements.
    *)

  val find : ('a -> bool) -> 'a array -> 'a
    (** [find p a] returns the first element of array [a]
  that satisfies the predicate [p].
  Raise [Not_found] if there is no value that satisfies [p] in the
  array [a].
    *)

  val findi : ('a -> bool) -> 'a array -> int
    (** [findi p a] returns the index of the first element of array [a]
  that satisfies the predicate [p].
  Raise [Not_found] if there is no value that satisfies [p] in the
  array [a].
    *)

  val filter : ('a -> bool) -> 'a array -> 'a array
    (** [filter p a] returns all the elements of the array [a]
  that satisfy the predicate [p].  The order of the elements
  in the input array is preserved.  *)

  val find_all : ('a -> bool) -> 'a array -> 'a array
    (** [find_all] is another name for {!Array.filter}. *)

  val partition : ('a -> bool) -> 'a array -> 'a array * 'a array
    (** [partition p a] returns a pair of arrays [(a1, a2)], where
  [a1] is the array of all the elements of [a] that
  satisfy the predicate [p], and [a2] is the array of all the
  elements of [a] that do not satisfy [p].
  The order of the elements in the input array is preserved. *)

  (** {6 Enumerations} *)

  val enum : 'a array -> 'a Enum.t
    (** Returns an enumeration of the elements of an array. *)

  val of_enum : 'a Enum.t -> 'a array
    (** Build an array from an enumeration. *)

  (** {6 Compatibility functions} *)

  (** These functions are reimplemented in extlib when they are missing from the stdlib *)

#if OCAML >= 403
  external create_float : int -> float array = "caml_make_float_vect"
#else
  val create_float : int -> float array
#endif

  val make_float : int -> float array

#if OCAML >= 406
  module Floatarray :
  sig
    external create : int -> floatarray = "caml_floatarray_create"
    external length : floatarray -> int = "%floatarray_length"
    external get : floatarray -> int -> float = "%floatarray_safe_get"
    external set : floatarray -> int -> float -> unit = "%floatarray_safe_set"
    external unsafe_get : floatarray -> int -> float = "%floatarray_unsafe_get"
    external unsafe_set : floatarray -> int -> float -> unit = "%floatarray_unsafe_set"
  end
#endif

  val for_all2 : ('a -> 'b -> bool) -> 'a array -> 'b array -> bool
  (** Same as {!Array.for_all}, but for a two-argument predicate.
     @raise Invalid_argument if the two arrays have different lengths. *)

  val exists2 : ('a -> 'b -> bool) -> 'a array -> 'b array -> bool
  (** Same as {!Array.exists}, but for a two-argument predicate.
     @raise Invalid_argument if the two arrays have different lengths. *)

  (** {6 Old functions} *)

  (** These functions are already part of the Ocaml standard library
      and have not been modified. Please refer to the Ocaml Manual for
      documentation. *)

  external length : 'a array -> int = "%array_length"
  external get : 'a array -> int -> 'a = "%array_safe_get"
  external set : 'a array -> int -> 'a -> unit = "%array_safe_set"
  external make : int -> 'a -> 'a array = "caml_make_vect"
  external create : int -> 'a -> 'a array = "caml_make_vect"
  val init : int -> (int -> 'a) -> 'a array
  val make_matrix : int -> int -> 'a -> 'a array array
  val create_matrix : int -> int -> 'a -> 'a array array
  val append : 'a array -> 'a array -> 'a array
  val concat : 'a array list -> 'a array
  val sub : 'a array -> int -> int -> 'a array
  val copy : 'a array -> 'a array
  val fill : 'a array -> int -> int -> 'a -> unit
  val blit : 'a array -> int -> 'a array -> int -> int -> unit
  val to_list : 'a array -> 'a list
  val of_list : 'a list -> 'a array
  val iter : ('a -> unit) -> 'a array -> unit
  val map : ('a -> 'b) -> 'a array -> 'b array
  val iteri : (int -> 'a -> unit) -> 'a array -> unit
  val mapi : (int -> 'a -> 'b) -> 'a array -> 'b array
  val fold_left : ('a -> 'b -> 'a) -> 'a -> 'b array -> 'a
  val fold_right : ('b -> 'a -> 'a) -> 'b array -> 'a -> 'a
  val sort : ('a -> 'a -> int) -> 'a array -> unit
  val stable_sort : ('a -> 'a -> int) -> 'a array -> unit
  val fast_sort : ('a -> 'a -> int) -> 'a array -> unit
  external unsafe_get : 'a array -> int -> 'a = "%array_unsafe_get"
  external unsafe_set : 'a array -> int -> 'a -> unit = "%array_unsafe_set"

#if OCAML >= 407
  (** [*_seq] functions were introduced in OCaml 4.07.0, and are _not_ implemented in extlib for older OCaml versions *)
  val to_seq : 'a array -> 'a Seq.t
  val to_seqi : 'a array -> (int * 'a) Seq.t
  val of_seq : 'a Seq.t -> 'a array
#endif

end
