(*
 * RefList - List reference
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
 *)

(** Reference on lists.

  RefList is a extended set of functions that manipulate list
  references.
*)

exception Empty_list
exception Invalid_index of int

type 'a t

val empty : unit -> 'a t
(** returns a new empty ref list *)

val is_empty : 'a t -> bool
(** tells if a ref list is empty *)

val clear : 'a t -> unit
(** removes all elements *)

val length : 'a t -> int
(** returns the number of elements - O(n) *)

val copy : dst:'a t -> src:'a t -> unit
(** makes a copy of a ref list - O(1) *)

val copy_list : dst:'a t -> src:'a list -> unit
(** makes a copy of a list - O(1) *)

val copy_enum : dst:'a t -> src:'a Enum.t -> unit
(** makes a copy of a enum *)

val of_list : 'a list -> 'a t
(** creates a ref list from a list - O(1) *)

val to_list : 'a t -> 'a list
(** returns the current elements as a list - O(1) *)

val of_enum : 'a Enum.t -> 'a t
(** creates a ref list from an enumeration *)

val enum : 'a t -> 'a Enum.t
(** returns an enumeration of current elements in the ref list *)

val append_enum : 'a t -> 'a Enum.t -> unit
(** appends the contents of the enumeration to the end of the ref list *)

val add : 'a t -> 'a -> unit
(** adds an element at the end - O(n) *)

val push : 'a t -> 'a -> unit
(** adds an element at the head - O(1) *)

val add_sort : ?cmp:('a -> 'a -> int) -> 'a t -> 'a -> unit
(** adds an element in a sorted list, using optional comparator
    or 'compare' as default. *)

val first : 'a t -> 'a
(** returns the first element or
    raises [Empty_list] if the ref list is empty *)

val last : 'a t -> 'a
(** returns the last element - O(n) or
    raises Empty_list if the ref list is empty *)

val pop : 'a t -> 'a
(** removes and returns the first element or
   raises [Empty_list] if the ref list is empty *)

val npop : 'a t -> int -> 'a list
(** removes and returns the n first elements or
   raises [Empty_list] if the ref list doed not
   containes enough elements *)

val hd : 'a t -> 'a
(** same as [first] *)

val tl : 'a t -> 'a t
(** returns a ref list containing the same elements
    but without the first one or
    raises [Empty_list] if the ref list is empty *)

val shuffle : 'a t -> unit
(** randomly shuffles the elements 
    using the module Random - O(n^2) *)

val rev : 'a t -> unit
(** reverses the ref list *)

(** {6 Functional Operations} *)

val iter : ('a -> unit) -> 'a t -> unit
(** apply the given function to all elements of the
    ref list, in respect with the order of the list *)

val find : ('a -> bool) -> 'a t -> 'a
(** find the first element that match
    the specified predicate
    raise Not_found if no element is found *)

val rfind : ('a -> bool) -> 'a t -> 'a
(** find the first element in the reversed ref list that
    match the specified predicate
    raise Not_found if no element is found *)

val find_exc : ('a -> bool) -> exn -> 'a t -> 'a
(** same as find but take an exception to be raised when
    no element is found as additional parameter *)

val exists : ('a -> bool) -> 'a t -> bool
(** tells if an element match the specified
    predicate *)

val for_all : ('a -> bool) -> 'a t -> bool
(** tells if all elements are matching the specified
    predicate *)

val map : ('a -> 'b) -> 'a t -> 'b t
(** apply a function to all elements
    and return the ref list constructed with
    the function returned values *)

val transform : ('a -> 'a) -> 'a t -> unit
(** transform all elements in the ref list
    using a function. *)

val map_list : ('a -> 'b) -> 'a t -> 'b list
(** apply a function to all elements
    and return the list constructed with
    the function returned values *)

val sort : ?cmp:('a -> 'a -> int) -> 'a t -> unit
(** sort elements using the specified comparator
    or compare as default comparator *)

val filter : ('a -> bool) -> 'a t -> unit
(** remove all elements that does not match the
    specified predicate *)

val remove : 'a t -> 'a -> unit
(** remove an element from the ref list
    raise Not_found if the element is not found *)

val remove_if : ('a -> bool) -> 'a t -> unit
(** remove the first element that does match the
    specified predicate
    raise Not_found if no element have been removed *)

val remove_all : 'a t -> 'a -> unit
(** remove all elements equals to the specified
    element from the ref list *)



(** Functions that operate on the [i]th element of a list.

    While it is sometimes necessary to perform these
    operations on lists (hence their inclusion here), the
    functions were moved to an inner module to prevent
    their overuse: all functions work in O(n) time. You
	might prefer to use [Array] or [DynArray] for constant
	time indexed element access.
*)
module Index : sig

	val index_of : 'a t -> 'a -> int
	(** return the index (position : 0 starting) of an element in
	    a ref list, using ( = ) for testing element equality
	    raise Not_found if no element was found *)

	val index : ('a -> bool) -> 'a t -> int
	(** return the index (position : 0 starting) of an element in
	    a ref list, using the specified comparator
	    raise Not_found if no element was found *)

	val at_index : 'a t -> int -> 'a
	(** return the element of ref list at the specified index
	    raise Invalid_index if the index is outside [0 ; length-1] *)

	val set : 'a t -> int -> 'a -> unit
	(** change the element at the specified index
	    raise Invalid_index if the index is outside [0 ; length-1] *)

	val remove_at : 'a t -> int -> unit
	(** remove the element at the specified index
	    raise Invalid_index if the index is outside [0 ; length-1] *)

end
