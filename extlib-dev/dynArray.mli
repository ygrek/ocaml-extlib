(*
 * DynArray - Resizeable Ocaml arrays
 * Copyright (C) 2003 Brian Hurt
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

(** Dynamic arrays.
   
	Dynamic arrays automatically adjust storage requirements as elements
	are added or removed from the array. They are a resizable equivalent
	of the Ocaml arrays.
*)

(** {6 Types} *)

type 'a t (* abstract *)
(** The abstract type of a dynamic array. *)

exception Invalid_arg of int * string * string
(** Exception on array operation :

	When an operation on an array fails, [Invalid_arg] is raised. The
	integer is the value that made the operation fail, the first string
	contains the function name that has been called and the second string
	contains the paramater name that made the operation fail.
*)

(** {6 Array creation} *)

val make : int -> 'a -> 'a t
(** [make size null] returns an array originally capable of holding [size]
	elements, with a null element of [null].  The null element is used to 
	fill unused elements of the underlying array.  
*)

val init : int -> int -> 'a -> (int -> 'a) -> 'a t
(** [init size len null f] returns an array capable of holding [size]
	elements, with a null element of [null].  The null element is used to 
	fill unused elements of the underlying array.  The first [len] elements
	are given values returned by the function [f], with element [idx]
	having the value [f idx].
 *)

(** {6 Array manipulation functions} *)

val empty : 'a t -> bool
(** Return true if the number of used elements in the array is 0. *)

val length : 'a t -> int
(** Return the number of used elements in the array - this is effectively
	it's length. *)

val get : 'a t -> int -> 'a
(** [get darr idx] gets the element in [darr] at index [idx]. If [darr] has
	[len] elements in it, then the valid indexs range from [0] to [len-1]. *)

val last : 'a t -> 'a
(** [last darr] returns the last element of [darr] *)

val set : 'a t -> int -> 'a -> unit
(** [set darr idx v] sets the element of [darr] at index [idx] to value
	[v].  The previous value is overwritten.  If [idx] is equal to
	[length darr] (i.e. the index is one past the end of the array), the
	array is expanded to hold the new element- in this case, the function
	behaves like [add].  Otherwise, the array is not expanded. *)

val insert : 'a t -> int -> 'a -> unit
(** [insert darr idx v] inserts [v] into [darr] at index [idx].  All elements
	of [darr] with an index greater than or equal to [idx] have their
	index incremented (are moved up one place) to make room for the new 
	element.
*)

val add : 'a t -> 'a -> unit
(** [add darr v] appends [v] onto [darr].  [v] becomes the new 
	last element of [darr]. *)

val append : 'a t -> 'a t -> 'a t
(** [append dst src] adds all elements of [src] to the end of [dst] and
	then returns [dst].  Note that [dst] is imperitively modified by this
	function. *)

val delete : 'a t -> int -> unit
(** [delete darr idx] deletes the element of [darr] at [idx].  All elements
	with an index greater than [idx] have their index decremented (are
	moved down one place) to fill in the hole. *)

val delete_last : 'a t -> unit
(** [delete_last darr] deletes the last element of [darr]. This is equivalent
	of doing [delete darr ((length darr) - 1)]. *)

val blit : 'a t -> int -> 'a t -> int -> int -> unit
(** [blit src srcidx dst dstidx len] copies [len] elements from [src]
	starting with index [srcidx] to [dst] starting at [dstidx].  The
	[dst] array can be in the same as [src], and even overlap.  This is a
	fast way to move blocks of elements around.
 *)

(** {6 Array copy and conversion} *)

val to_list : 'a t -> 'a list
(** [to_list darr] returns the elements of [darr] in order as a list. *)

val to_array : 'a t -> 'a array
(** [to_array darr] returns the elements of [darr] in order as an array. *)

val of_list : 'a -> 'a list -> 'a t
(** [of_list null lst] returns a dynamic array with the elements of [lst] in
	it in order, and [null] as it's null element.
*)

val of_array : 'a -> 'a array -> 'a t
(** [of_array null arr] returns an array with the elements of [arr] in it
	in order, and [null] as it's null element. 
*)

val copy : 'a t -> 'a t
(** [copy src] returns a fresh copy of [src], such that no modification of
	[src] affects the copy, or vice versa (all new memory is allocated for
	the copy).  
*)

val sub : 'a t -> int -> int -> 'a t
(** [sub darr start len] returns an array holding the subset of [len] 
	elements from [darr] starting with the element at index [idx].
*)

(** {6 Array functional support} *)

val iter : ('a -> unit) -> 'a t -> unit
(** [iter f darr] calls the function [f] on every element of [darr].  It
	is equivalent to for i = 0 to ([length darr]) do f ([get darr i]) done;
*)

val iteri : (int -> 'a -> unit) -> 'a t -> unit
(** [iter f darr] calls the function [f] on every element of [darr].  It
	is equivalent to for i = 0 to ([length darr]) do f i ([get darr i]) done;
*)

val map : ('a -> 'b) -> 'b -> 'a t -> 'b t
(** [map f nulldst darr] applies the function [f] to every element of [darr]
	and creates a dynamic array from the results - similiar to [List.map] or
	[Array.map].  [nulldst] is the null element of the returned dynamic array.
*)

val mapi : (int -> 'a -> 'b) -> 'b -> 'a t -> 'b t
(** [mapi f nulldst darr] applies the function [f] to every element of [darr]
	and creates a dynamic array from the results - similiar to [List.mapi] or
	[Array.mapi]. [nulldst] is the null element of the returned dynamic array.
*)

val fold_left : ('a -> 'b -> 'a) -> 'a -> 'b t -> 'a
(** [fold_left f x darr] computes 
	[f ( ... ( f ( f (get darr 0) x) (get darr 1) ) ... ) (get darr n-1)],
	similiar to [Array.fold_left] or [List.fold_left]. *)

val fold_right : ('a -> 'b -> 'b) -> 'a t -> 'b -> 'b
(** [fold_right f darr x] computes
	[ f (get darr 0) (f (get darr 1) ( ... ( f (get darr n-1) x ) ... ) ) ]
	similiar to [Array.fold_right] or [List.fold_right]. *)

(** {6 Array enumerations} *)

val enum : 'a t -> 'a Enum.t
(** [enum darr] returns the enumeration of [darr] *)

val sub_enum : 'a t -> int -> int -> 'a Enum.t
(** [sub_enum darr idx len] returns an enumeration of a subset of [len]
	elements of [darr], starting with the element at index [idx]. *)

val of_enum : 'a -> 'a Enum.t -> 'a t
(** [of_enum nullval e] returns an t that holds, in order, the 
	elements of [e].
*)

val insert_enum : 'a t -> int -> 'a Enum.t -> unit
(** [insert_enum darr idx e] inserts the elements of [e] into [darr]
	so the first element of [e] has index [idx], the second index [idx]+1,
	etc.   All the elements of [darr] with index greater than or equal to
	[idx] are moved up by the number of elements in [e] to make room. *)

val set_enum : 'a t -> int -> 'a Enum.t -> unit
(** [set_enum darr idx e] sets the elements from [e] into [darr],
	so the first element of [e] has index [idx], etc.  The elements with
	indexs [idx], [idx]+1, etc. are overwritten. *)

(* Reversed enum functions *)

val rev_enum : 'a t -> 'a Enum.t
(** [rev_enum darr] returns the reverse enumeration of [darr]- elements are
	enumerated in reverse order - from largest index to smallest. *)

val sub_rev_enum : 'a t -> int -> int -> 'a Enum.t
(** [sub_rev_enum darr idx len] returns an enumeration of a subset of [len]
	elements of [darr], starting with the element at index [idx]+[len]-1.
	The elements are returned in reverse order- from highest index to
	lowest index.  So the last element returned from [e] becomes the
	element at index [idx]. *)

val of_rev_enum : 'a -> 'a Enum.t -> 'a t
(** [of_rev_enum nullval e] returns a dynamic array that holds, in reverse
	order, the elements of [e].  The first element returned from [e] becomes
	the highest indexed element of the returned dynamic array, and so on.
	Otherwise it acts like [of_enum].
*)

val insert_rev_enum : 'a t -> int -> 'a Enum.t -> unit
(** [insert_rev_enum darr idx e] inserts the elements of [e] into [darr]
	so the first element of [e] has index [idx]+[len]-1, the second index 
	[idx]+[len]-2, etc, where [len] is the count of elements initially in 
	[e].   The last element from [e] becomes the element at index [idx].  
	Otherwise it acts like [insert_enum].
*)

val set_rev_enum : 'a t -> int -> 'a Enum.t -> unit
(** [set_rev_enum darr idx e] sets the elements from [e] into [darr],
	so the first element of [e] has index [idx]+[len]-1, etc, where [len]
	is the count of elements initially in [e].  The last element of [e]
	has index [idx].  Otherwise it acts like [set_enum].
*)

(** {6 Array resizers} *)

type resizer_t = currslots:int -> oldlength:int -> newlength:int -> int
(** The type of a resizer function.

	Resizer functions are called whenever elements are added to
	or removed from the dynamic array to determine what the current number of
	storage spaces in the array should be.  The three named arguments
	passed to a resizer are the current number of storage spaces in
	the array, the length of the array before the elements are
	added or removed, and the length the array will be after the
	elements are added or removed.  If elements are being added, newlength
	will be larger than oldlength, if elements are being removed,
	newlength will be smaller than oldlength. If the resizer function
	returns exactly oldlength, the size of the array is only changed when
	adding an element while there is not enough space for it.

	By default, all dynamic arrays are created with the [default_resizer].
	When a dynamic array is created from another dynamic array (using [copy],
	[map] , etc. ) the resizer of the copy will be the same as the original
	dynamic array resizer. To change the resizer, use the [set_resizer]
	function.
*)

val set_resizer : 'a t -> resizer_t -> unit
(** Change the resizer for this array. *)	

val get_resizer : 'a t -> resizer_t
(** Get the current resizer function for a given array *)

val default_resizer : resizer_t
(** The default resizer function the library is using - in this version
	of DynArray, this is the [exponential_resizer] but should change in
	next versions.
*)

val exponential_resizer : resizer_t
(** The exponential resizer- The default resizer except when the resizer
	is being copied from some other darray.

	[exponential_resizer] works by doubling or halving the number of
	slots until they "fit".  If the number of slots is less than the
	new length, the number of slots is doubled until it is greater
	than the new length (or Sys.max_array_size is reached).  

	If the number of slots is more than four times the new length,
	the number of slots is halved until it is less than four times the
	new length.

	Allowing darrays to fall below 25% utilization before shrinking them
	prevents "thrashing".  Consider the case where the caller is constantly
	adding a few elements, and then removing a few elements, causing
	the length to constantly cross above and below a power of two.
	Shrinking the array when it falls below 50% would causing the
	underlying array to be constantly allocated and deallocated.
	A few elements would be added, causing the array to be reallocated
	and have a usage of just above 50%.  Then a few elements would be
	remove, and the array would fall below 50% utilization and be
	reallocated yet again.  The bulk of the array, untouched, would be
	copied and copied again.  By setting the threshold at 25% instead,
	such "thrashing" only occurs with wild swings- adding and removing
	huge numbers of elements (more than half of the elements in the array).

	[exponential_resizer] is a good performing resizer for most 
	applications.  A list allocates 2 words for every element, while an
	array (with large numbers of elements) allocates only 1 word per
	element (ignoring unboxed floats).  On insert, [exponential_resizer]
	keeps the amount of wasted "extra" array elements below 50%, meaning
	that less than 2 words per element are used.  Even on removals
	where the amount of wasted space is allowed to rise to 75%, that
	only means that darray is using 4 words per element.  This is
	generally not a signifigant overhead.

	Furthermore, [exponential_resizer] minimizes the number of copies
	needed- appending n elements into an empty darray with initial size
	0 requires between n and 2n elements of the array be copied- O(n)
	work, or O(1) work per element (on average).  A similiar argument
	can be made that deletes from the end of the array are O(1) as
	well (obviously deletes from anywhere else are O(n) work- you
	have to move the n or so elements above the deleted element down).

 *)

val step_resizer : int -> resizer_t
(** The stepwise resizer- another example of a resizer function, this
	time of a parameterized resizer.
   
	The resizer returned by [step_resizer step] returns the smallest 
	multiple of [step] larger than [newlength] if [currslots] is less 
	then [newlength]-[step] or greater than [newlength].

	For example, to make an darray with a step of 10, a length
	of len, and a null of null, you would do:
	[make] ~resizer:([step_resizer] 10) len null
 *)

val conservative_exponential_resizer : resizer_t
(** [conservative_exponential_resizer] is an example resizer function
	which uses the oldlength parameter.  It only shrinks the array
	on inserts- no deletes shrink the array, only inserts.  It does
	this by comparing the oldlength and newlength parameters.  Other
	than that, it acts like [exponential_resizer].
*)