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

(** Enumeration over abstract collection of elements.

 Enumerations are entirely functional and most of the operations does not
 actually requires the allocation of data structures. Using enumerations
 to manipulate data is then efficient and simple. All data structures in
 ExtLib such as lists, arrays, etc. have support to convert from and to
 enumerations.
*)


type 'a t

(** {6 Final functions}

 Theses functions are consuming all the enumeration until
 its end (or an exception is raised).
*)

val iter : ('a -> unit) -> 'a t -> unit
(** [iter f e] calls the function [f] with all elements of [e]. *)

val iter2 : ('a -> 'b -> unit) -> 'a t -> 'b t -> unit
(** [iter2 f e1 e2] calls the function [f] with the next element of [e] and
 the next element of [e2] until one of the two enumerations ends. *)

val fold : ('a -> 'b -> 'b) -> 'b -> 'a t -> 'b
(** [fold f v e] returns [f (... (f (f v a1) a2) ...) aN] where a1..N are
 the elements of [e]. *)

val fold2 : ('a -> 'b -> 'c -> 'c) -> 'c -> 'a t -> 'b t -> 'c
(** [fold2] is similar to [fold] but will fold over two enumerations at the
 same time until one of the two enumerations ends. *)

(** Indexed fuctions : these functions are similar to previous ones
 except that they are calling the function with one additional argument which
 is an index starting at 0 and incremented after each call to the function. *)

val iteri : (int -> 'a -> unit) -> 'a t -> unit

val iter2i : ( int -> 'a -> 'b -> unit) -> 'a t -> 'b t -> unit

val foldi : (int -> 'a -> 'b -> 'b) -> 'b -> 'a t -> 'b

val fold2i : (int -> 'a -> 'b -> 'c -> 'c) -> 'c -> 'a t -> 'b t -> 'c

(** {6 Useful functions} *)

val init : int -> (int -> 'a) -> 'a t
(** [init n f] create a new enumeration over elements
  [f 0, f 1, ..., f (n-1)] *)

val find : ('a -> bool) -> 'a t -> 'a
(** [find f e] returns the first element [x] of [e] such as [f x] returns
 [true], or raises [Not_found] if no element can be found. Since [find] is
 consuming the enumeration, you can use it several times on the same
 enumeration to find the next element. *)

val empty : 'a t -> bool
(** [empty e] returns true if [e] does not contains any element. *)

val peek : 'a t -> 'a option
(** [peek e] returns [None] if [e] is empty or [Some x] where [x] is
 the next element of [e]. The element is not removed from the enumeration. *)

val push : 'a t -> 'a -> unit
(** [push e x] will add [x] at the beginning of [e]. *)

val get : 'a t -> 'a option
(** [get e] returns [None] if [e] is empty or [Some x] where [x] is
 the next element of [e]. The element is removed from the enumeration. *)

val clone : 'a t -> 'a t
(** [clone e] creates a new enumeration that is copy of [e]. If [e]
 is consumed by later operations, the clone will not get affected. *)

val force : 'a t -> unit
(** [force e] forces the application of all lazy functions and the
 enumeration of all elements. An efficient intermediate data structure
 of enumerated elements is constructed and [e] will now enumerate over
 that data structure. *)

val count : 'a t -> int
(** [count e] returns the number of remaining elements in [e].
 Depending of the underlying data structure that is implementing the
 enumeration functions, the count operation can be costly, and even sometimes
 can cause a call to [force]. *)

(** {6 Lazy functions}

 Theses functions are lazy, that means that they will create a new modified
 enumeration without actually enumerating any element until they are asked
 to do so by the programmer (using one of the functions above).
 
 When the resulting enumerations of theses functions are consumed, the
 underlying enumerations they were created from are also consumed. *)

val map : ('a -> 'b) -> 'a t -> 'b t
(** [map f e] returns an enumeration over [(f a1, f a2, ... , f aN)] where
 a1...N are the elements of [e]. *)

val mapi : (int -> 'a -> 'b) -> 'a t -> 'b t
(** [mapi] is similar to [map] except that [f] is passed one extra argument
 which is the index of the element in the enumeration, starting from 0. *)

val filter : ('a -> bool) -> 'a t -> 'a t
(** [filter f e] returns an enumeration over all elements [x] of [e] such
 as [f x] returns [true]. *)

val filter_map : ('a -> 'b option) -> 'a t -> 'b t
(** [filter_map f e] returns an enumeration over all elements [x] such as
 [f y] returns [Some x] , where [y] is an element of [e]. *)

val append : 'a t -> 'a t -> 'a t
(** [append e1 e2] returns an enumeration that will enumerate over all
 elements of [e1] followed by all elements of [e2]. *)

val concat : 'a t t -> 'a t
(** [concat e] returns an enumeration over all elements of all enumerations
 of [e]. *)

(** {6 Creating enumerations} 

 Although enumerations over several data structures are already implemented
 in ExtLib, you might want to create your own enumerations over your own data
 structures. *)

exception No_more_elements
(** This exception is raised by the [next] function when no more elements
 can be enumerated. It should NOT be used anywhere else than in a [next]
 function used for [make] or [from] since it is used internaly. *)

val from : (unit -> 'a) -> 'a t
(** [from next] is creating an enumeration using only a [next] function.
 Such function returns the next element of the enumeration or raise
 [No_more_elements] when no more elements can be enumerated. Since the
 enumeration definition is uncomplete, a call to [clone] or [count] will
 result in a call to [force] that will enumerate all elements in order to
 return a correct value. *)

val make : next:(unit -> 'a) -> count:(unit -> int) -> clone:(unit -> 'a t) -> 'a t
(** this function is creating a fully defined enumeration.
	{ul {li the [next] function will return the next element of the
	enumeration or raise [No_more_elements] if the underlying data structure
	does not have any more elements to enumerate.}
	{li the [count] function will return the actual number of remaining
	elements in the enumeration.}
	{li the [clone] function will create a clone of the enumeration. }}
 
	{i (for some samples on how to correctly use [make], you can have a look
		at implementation of [ExtList.enum]. }
*)

(**/**)

val fast_count : 'a t -> bool
(** For users worried about the speed of [count] you can call the [fast_count]
    function that will give an hint about [count] implementation. Basicly, if
    the enumeration has been created with [make] or [init] or if [force] has
	been called on it, then [fast_count] will return true. *)
