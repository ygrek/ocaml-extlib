(*
 * ExtList - additional and modified functions for lists.
 * Copyright (C) 2003 Brian Hurt
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

(** Additional and modified functions for lists.

  The OCaml standard library provides a module for list functions.
  This ExtList module can be used to override the List module or
  as a standalone module. It provides new functions and modify
  the behavior of some other ones (in particular all functions
  are now {b tail-recursive}).
*)

module List :
    sig

    type 'a t = 'a list
#if OCAML >= 408
    = [] | (::) of 'a * 'a list
#endif

  (** {6 New functions} *)

  val init : int -> (int -> 'a) -> 'a list
  (** Similar to [Array.init], [init n f] returns the list containing
   the results of (f 0),(f 1).... (f (n-1)).
   Raise [Invalid_arg "ExtList.init"] if n < 0.
   Uses stdlib implementation in OCaml 4.06.0 and newer.
  *)

  val make : int -> 'a -> 'a list
    (** Similar to [String.make], [make n x] returns a
      * list containing [n] elements [x].
          *)

  val first : 'a list -> 'a
  (** Returns the first element of the list, or raise [Empty_list] if
   the list is empty (similar to [hd]). *)

  val last : 'a list -> 'a
  (** Returns the last element of the list, or raise [Empty_list] if
   the list is empty. This function takes linear time. *)

  val iteri : (int -> 'a -> unit) -> 'a list -> unit
  (** [iteri f l] will call [(f 0 a0);(f 1 a1) ... (f n an)] where
   [a0..an] are the elements of the list [l]. *)

  val mapi : (int -> 'a -> 'b) -> 'a list -> 'b list
  (** [mapi f l] will build the list containing
   [(f 0 a0);(f 1 a1) ... (f n an)] where [a0..an] are the elements of
   the list [l]. *)

  val rfind : ('a -> bool) -> 'a list -> 'a
  (** [rfind p l] returns the last element [x] of [l] such as [p x] returns
   [true] or raises [Not_found] if such element as not been found. *)

  val find_exc : ('a -> bool) -> exn -> 'a list -> 'a
  (** [find_exc p e l] returns the first element of [l] such as [p x]
   returns [true] or raises [e] if such element as not been found. *)

  val findi : (int -> 'a -> bool) -> 'a list -> (int * 'a)
  (** [findi p e l] returns the first element [ai] of [l] along with its
   index [i] such that [p i ai] is true, or raises [Not_found] if no
   such element has been found. *)

  val unique : ?cmp:('a -> 'a -> bool) -> 'a list -> 'a list
  (** [unique cmp l] returns the list [l] without any duplicate element.
   Default comparator ( = ) is used if no comparison function specified. *)

  val filter_map : ('a -> 'b option) -> 'a list -> 'b list
  (** [filter_map f l] call [(f a0) (f a1).... (f an)] where [a0..an] are
   the elements of [l]. It returns the list of elements [bi] such as
   [f ai = Some bi] (when [f] returns [None], the corresponding element of
   [l] is discarded). *)

  val find_map_exn : ('a -> 'b option) -> 'a list -> 'b
  (** [find_map_exn pred list] finds the first element of [list] for which
      [pred element] returns [Some r].  It returns [r] immediately
      once found or raises [Not_found] if no element matches the
      predicate.  See also {!filter_map}.
      This function was called [find_map] prior to extlib 1.7.7, but had to
      be renamed to stay compatible with OCaml 4.10.
  *)

  val find_map_opt : ('a -> 'b option) -> 'a list -> 'b option
  (** same as find_map_exn but returning option *)

  val find_map : ('a -> 'b option) -> 'a list -> 'b option
  (** same as find_map_opt *)

  val split_nth : int -> 'a list -> 'a list * 'a list
  (** [split_nth n l] returns two lists [l1] and [l2], [l1] containing the
   first [n] elements of [l] and [l2] the others. Raise [Invalid_index] if
   [n] is outside of [l] size bounds. *)

  val filteri : (int -> 'a -> bool) -> 'a list -> 'a list
  (** Same as {!List.filter}, but the predicate is applied to the index of
     the element as first argument (counting from 0), and the element
     itself as second argument.
  *)

  val fold_left_map : ('a -> 'b -> 'a * 'c) -> 'a -> 'b list -> 'a * 'c list
  (** [fold_left_map] is  a combination of [fold_left] and [map] that threads an
    accumulator through calls to [f] *)

  val remove : 'a list -> 'a -> 'a list
  (** [remove l x] returns the list [l] without the first element [x] found
   or returns  [l] if no element is equal to [x]. Elements are compared
   using ( = ). *)

  val remove_if : ('a -> bool) -> 'a list -> 'a list
  (** [remove_if cmp l] is similar to [remove], but with [cmp] used
   instead of ( = ). *)

  val remove_all : 'a list -> 'a -> 'a list
  (** [remove_all l x] is similar to [remove] but removes all elements that
   are equal to [x] and not only the first one. *)

  val take : int -> 'a list -> 'a list
  (** [take n l] returns up to the [n] first elements from list [l], if
   available. *)

  val drop : int -> 'a list -> 'a list
  (** [drop n l] returns [l] without the first [n] elements, or the empty
   list if [l] have less than [n] elements. *)

  val takewhile : ('a -> bool) -> 'a list -> 'a list
    (** [takewhile f xs] returns the first elements of list [xs]
        which satisfy the predicate [f]. *)

  val dropwhile : ('a -> bool) -> 'a list -> 'a list
    (** [dropwhile f xs] returns the list [xs] with the first
        elements satisfying the predicate [f] dropped. *)

  (** {6 Enum functions} *)

  (** Enumerations are important in ExtLib, they are a good way to work with
   abstract enumeration of elements, regardless if they are located in a list,
   an array, or a file. *)

  val enum : 'a list -> 'a Enum.t
  (** Returns an enumeration of the elements of a list. *)

  val of_enum : 'a Enum.t -> 'a list
  (** Build a list from an enumeration. *)

  (** {6 Compatibility functions} *)

  val cons : 'a -> 'a list -> 'a list

  val assoc_opt : 'a -> ('a * 'b) list -> 'b option
  val assq_opt : 'a -> ('a * 'b) list -> 'b option

  val find_opt : ('a -> bool) -> 'a list -> 'a option
  val nth_opt : 'a list -> int -> 'a option

  val compare_lengths : 'a list -> 'b list -> int
  val compare_length_with : 'a list -> int -> int

  (** {6 Modified functions} *)

  (** Some minor modifications have been made to the specification of some
   functions, especially concerning exceptions raised. *)

  val hd : 'a list -> 'a
  (** Returns the first element of the list or raise [Empty_list] if the
   list is empty. *)

  val tl : 'a list -> 'a list
  (** Returns the list without its first elements or raise [Empty_list] if
   the list is empty. *)

  val nth : 'a list -> int -> 'a
  (** [nth l n] returns the n-th element of the list [l] or raise
   [Invalid_index] is the index is outside of [l] bounds. *)

  val sort : ?cmp:('a -> 'a -> int) -> 'a list -> 'a list
  (** Sort the list using optional comparator (by default [compare]). *)

  (** The following functions have been improved so all of them are
   tail-recursive. They have also been modified so they no longer
   raise [Invalid_arg] but [Different_list_size] when used on two
   lists having a different number of elements. *)

  val map2 : ('a -> 'b -> 'c) -> 'a list -> 'b list -> 'c list
  val rev_map2 : ('a -> 'b -> 'c) -> 'a list -> 'b list -> 'c list
  val iter2 : ('a -> 'b -> unit) -> 'a list -> 'b list -> unit
  val fold_left2 : ('a -> 'b -> 'c -> 'a) -> 'a -> 'b list -> 'c list -> 'a
  val fold_right2 : ('a -> 'b -> 'c -> 'c) -> 'a list -> 'b list -> 'c -> 'c
  val for_all2 : ('a -> 'b -> bool) -> 'a list -> 'b list -> bool
  val exists2 : ('a -> 'b -> bool) -> 'a list -> 'b list -> bool
  val combine : 'a list -> 'b list -> ('a * 'b) list


  (** {6 Improved functions} *)

  (** The following functions have the same behavior as the [List]
    module ones but are tail-recursive. That means they will not
    cause a [Stack_overflow] when used on very long list.

    The implementation might be a little more slow in bytecode,
    but compiling in native code will not affect performances. *)

  val map : ('a -> 'b) -> 'a list -> 'b list
  val append : 'a list -> 'a list -> 'a list
  val flatten : 'a list list -> 'a list
  val concat : 'a list list -> 'a list
  val fold_right : ('a -> 'b -> 'b) -> 'a list -> 'b -> 'b
  val remove_assoc : 'a -> ('a * 'b) list -> ('a * 'b) list
  val remove_assq : 'a -> ('a * 'b) list -> ('a * 'b) list
  val split : ('a * 'b) list -> 'a list * 'b list

  (** The following functions were already tail-recursive in the [List]
    module but were using [List.rev] calls. The new implementations
    have better performances. *)

  val filter : ('a -> bool) -> 'a list -> 'a list
  val find_all : ('a -> bool) -> 'a list -> 'a list
  val partition : ('a -> bool) -> 'a list -> 'a list * 'a list

  (** {6 Older functions} *)

  (** These functions are already part of the Ocaml standard library
    and have not been modified. Please refer to the Ocaml Manual for
    documentation. *)

  val length : 'a list -> int
  val rev_append : 'a list -> 'a list -> 'a list
  val rev : 'a list -> 'a list
  val rev_map : ('a -> 'b) -> 'a list -> 'b list
  val iter : ('a -> unit) -> 'a list -> unit
  val fold_left : ('b -> 'a -> 'b) -> 'b -> 'a list -> 'b
  val for_all : ('a -> bool) -> 'a list -> bool
  val exists : ('a -> bool) -> 'a list -> bool
  val find : ('a -> bool) -> 'a list -> 'a

  val mem : 'a -> 'a list -> bool
  val memq : 'a -> 'a list -> bool
  val assoc : 'a -> ('a * 'b) list -> 'b
  val assq : 'a -> ('a * 'b) list -> 'b
  val mem_assoc : 'a -> ('a * 'b) list -> bool
  val mem_assq : 'a -> ('a * 'b) list -> bool


  val stable_sort : ('a -> 'a -> int) -> 'a list -> 'a list
  val fast_sort : ('a -> 'a -> int) -> 'a list -> 'a list
  val merge : ('a -> 'a -> int) -> 'a list -> 'a list -> 'a list

#if OCAML >= 402
  val sort_uniq : ('a -> 'a -> int) -> 'a list -> 'a list
  (** Same as {!List.sort}, but also remove duplicates.
      @since 4.02.0 *)
#endif

#if OCAML >= 407
  (** [*_seq] functions were introduced in OCaml 4.07.0, and are _not_ implemented in extlib for older OCaml versions *)
  val to_seq : 'a list -> 'a Seq.t
  val of_seq : 'a Seq.t -> 'a list
#endif

#if OCAML >= 412
  val partition_map : ('a -> ('b, 'c) Either.t) -> 'a list -> 'b list * 'c list
  (** [partition_map f l] returns a pair of lists [(l1, l2)] such that,
      for each element [x] of the input list [l]:
      - if [f x] is [Left y1], then [y1] is in [l1], and
      - if [f x] is [Right y2], then [y2] is in [l2].

      The output elements are included in [l1] and [l2] in the same
      relative order as the corresponding input elements in [l].

      In particular, [partition_map (fun x -> if f x then Left x else Right x) l]
      is equivalent to [partition f l].

      This function was introduced in OCaml 4.12.0, and is _not_ implemented in extlib for older OCaml versions
  *)
#endif

  val concat_map : ('a -> 'b list) -> 'a list -> 'b list

val equal : ('a -> 'a -> bool) -> 'a list -> 'a list -> bool
(** [equal eq [a1; ...; an] [b1; ..; bm]] holds when
    the two input lists have the same length, and for each
    pair of elements [ai], [bi] at the same position we have
    [eq ai bi].

    Note: the [eq] function may be called even if the
    lists have different length. If you know your equality
    function is costly, you may want to check {!compare_lengths}
    first.
*)

val compare : ('a -> 'a -> int) -> 'a list -> 'a list -> int
(** [compare cmp [a1; ...; an] [b1; ...; bm]] performs
    a lexicographic comparison of the two input lists,
    using the same ['a -> 'a -> int] interface as {!Stdlib.compare}:

    - [a1 :: l1] is smaller than [a2 :: l2] (negative result)
      if [a1] is smaller than [a2], or if they are equal (0 result)
      and [l1] is smaller than [l2]
    - the empty list [[]] is strictly smaller than non-empty lists

    Note: the [cmp] function will be called even if the lists have
    different lengths.
*)

  (** {6 Exceptions} *)

  exception Empty_list
  (** [Empty_list] is raised when an operation applied on an empty list
    is invalid : [hd] for example. *)

  exception Invalid_index of int
  (** [Invalid_index] is raised when an indexed access on a list is
    out of list bounds. *)

  exception Different_list_size of string
  (** [Different_list_size] is raised when applying functions such as
    [iter2] on two lists having different size. *)


end

val ( @ ) : 'a list -> 'a list -> 'a list
(** the new implementation for ( @ ) operator, see [List.append]. *)
