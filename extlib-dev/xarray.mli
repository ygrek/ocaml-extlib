
(*
 * Xarray - Resizeable Ocaml arrays
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

(** Resizable arrays.
   
	Resizable arrays automatically adjust storage requirements as elements
	are added or removed from the array.
  *)

(** {6 Types} *)

type 'a t (* abstract *)
(** The abstract type of a resizable array. *)

type resizer_t = currslots:int -> oldlength:int -> newlength:int -> int
(** The type of a resizer function.

	Resizer functions are given as optional arguments when a new xarray
	is being allocated.  They are called whenever elements are added to
	or removed from the xarray to determine what the current number of
	storage spaces in the xarray should be.  The three named arguments
	passed to a resizer are the current number of storage spaces in
	the xarray, the length of the xarray before the elements are
	added or removed, and the length the xarray will be after the
	elements are added or removed.  If elements are being added, newlength
	will be larger than oldlength, if elements are being removed,
	newlength will be smaller than oldlength.

	See [exponential_resizer] and [step_resizer] for example resizer
	functions.
*)

exception Invalid_arg of int * string * string
(** Exception on array operation

	When an operation on an xarray fails, [Invalid_arg] is raised. The
	integer is the value that made the operation fail, the first string
	contains the function name that has been called and the second string
	contains the paramater name that made the operation fail.
*)

(** {6 Array creation} *)

val make : int -> 'a -> 'a t
(** [make size null] returns an xarray originally capable of holding [size]
	elements, with a null element of [null].  The null element is used to 
	fill unused elements of the underlying array.  

	The default resizer function used is [exponential_resizer].

*)

val init : int -> int -> 'a -> (int -> 'a) -> 'a t
(** [init size len null f] returns an xarray capable of holding [size]
	elements, with a null element of [null].  The null element is used to 
	fill unused elements of the underlying array.  The first [len] elements
	are given values returned by the function [f], with element [idx]
	having the value [f idx].  

	The default resizer function used is [exponential_resizer].

 *)

val set_resizer : 'a t -> resizer_t -> unit
(** 
	Change the resizer for this array. When an is copied, the same resizer
	will be used for the copy.
*)	

(** {6 Array manipulation functions} *)

val empty : 'a t -> bool
(** Return true if the number of used elements in the xarray is 0. *)

val length : 'a t -> int
(** Return the number of used elements in the xarray - this is effectively
	it's length. *)

val get : 'a t -> int -> 'a
(** [get xarr idx] gets the element in [xarr] at index [idx]. If [xarr] has
	[len] elements in it, then the valid indexs range from [0] to [len-1]. *)

val last : 'a t -> 'a
(** [last xarr] returns the last element of [xarr], or throws 
	[Invalid_arg 0 "Xarray.last"] *)

val set : 'a t -> int -> 'a -> unit
(** [set xarr idx v] sets the element of [xarr] at index [idx] to value
	[v].  The previous value is overwritten.  If [idx] is equal to
	[length xarr] (i.e. the index is one past the end of the xarray), the
	xarray is expanded to hold the new element- in this case, the function
	behaves like [add].  Otherwise, the array is not expanded. *)

val insert : 'a t -> int -> 'a -> unit
(** [insert xarr idx v] inserts [v] into [xarr] at index [idx].  All elements
	of [xarr] with an index greater than or equal to [idx] have their
	index incremented (are moved up one place) to make room for the new 
	element.
*)

val add : 'a t -> 'a -> unit
(** [add xarr v] appends [v] onto [xarr].  [v] becomes the new 
	last element of [xarr]. *)

val append : 'a t -> 'a t -> 'a t
(** [append dst src] adds all elements of [src] to the end of [dst] and
	then returns [dst].  Note that [dst] is imperitively modified by this
	function. *)

val delete : 'a t -> int -> unit
(** [delete xarr idx] deletes the element of [xarr] at [idx].  All elements
	with an index greater than [idx] have their index decremented (are
	moved down one place) to fill in the hole. *)

val delete_last : 'a t -> unit
(** [delete_last xarr] deletes the last element of [xarr].  This is 
	equivelent to going [delete xarr ((length xarr) - 1)]. *)

val blit : 'a t -> int -> 'a t -> int -> int -> unit
(** [blit src srcidx dst dstidx len] copies [len] elements from [src]
	starting with index [srcidx] to [dst] starting at [dstidx].  The
	sub-xarrays can be in the same xarray, and even overlap.  This is a
	fast way to move blocks of elements around.
 *)

(** {6 Array copy and conversion} *)

val to_list : 'a t -> 'a list
(** [to_list xarr] returns the elements of [xarr] in order as a list. *)

val to_array : 'a t -> 'a array
(** [to_array xarr] returns the elements of [xarr] in order as an array. *)

val of_list : 'a -> 'a list -> 'a t
(** [of_list null lst] returns an xarray with the elements of [lst] in it
	in order, and [null] as it's null element.

	The default resizer function used is [exponential_resizer].

*)

val of_array : 'a -> 'a array -> 'a t
(** [of_array null arr] returns an xarray with the elements of [arr] in it
	in order, and [null] as it's null element.  

	The default resizer function used is [exponential_resizer].

*)

val copy : 'a t -> 'a t
(** [copy src] returns a fresh copy of [src], such that no modification of
	[src] affects the copy, or vice versa (all new memory is allocated for
	the copy).  

	The initial size of the returned xarray is the same as the current
	size of the source xarray.  The default resizer function used is the 
	resizer of the source xarray.

*)

val sub : 'a t -> int -> int -> 'a t
(** [sub xarr start len] returns an xarray holding the subset of [len] 
	elements from [xarr] starting with the element at index [idx].  A
	new resizing strategy can be provided- if no strategy is provided,
	the strategy of [xarr] is used.  

	The initial size of the returned xarray is calculated by calling 
	[resizer ~currslots:0 ~oldlength:0 ~newlength:len].  The default 
	resizer function used is the resizer of the source xarray

*)

(** {6 Array functional support} *)

val iter : ('a -> unit) -> 'a t -> unit
(** [iter f xarr] calls the function [f] on every element of [xarr].  It
	is equivelent to for i = 0 to ([length xarr]) do f ([get xarr i]) done; *)

val iteri : (int -> 'a -> unit) -> 'a t -> unit
(** [iter f xarr] calls the function [f] on every element of [xarr].  It
	is equivelent to for i = 0 to ([length xarr]) do f i ([get xarr i]) done; *)

val map : ('a -> 'b) -> 'b -> 'a t -> 'b t
(** [map f nulldst xarr] applies the function [f] to every element of [xarr]
	and creates an xarray from the results- similiar to [List.map] or
	[Array.map].  [nulldst] is the null element of the returned xarray.

	The initial size of the returned xarray is the same as that of the
	source xarray.  The default resizer is that of the source xarray.
*)

val mapi : (int -> 'a -> 'b) -> 'b -> 'a t -> 'b t
(** [mapi f nulldst xarr] applies the function [f] to every element of [xarr]
	and creates an xarray from the results- similiar to [List.mapi] or
	[Array.mapi].  [nulldst] is the null element of the returned xarray.

	The initial size of the returned xarray is the same as that of the
	source xarray.  The default resizer is that of the source xarray.
*)

val fold_left : ('a -> 'b -> 'a) -> 'a -> 'b t -> 'a
(** [fold_left f x xarr] computes 
	[f ( ... ( f ( f (get xarr 0) x) (get xarr 1) ) ... ) (get xarr n-1)],
	similiar to [Array.fold_left] or [List.fold_left]. *)

val fold_right : ('a -> 'b -> 'b) -> 'a t -> 'b -> 'b
(** [fold_right f xarr x] computes
	[ f (get xarr 0) (f (get xarr 1) ( ... ( f (get xarr n-1) x ) ... ) ) ]
	similiar to [Array.fold_right] or [List.fold_right]. *)

(** {6 Array enumerations} *)

val enum : 'a t -> 'a Enum.t
(** [enum xarr] returns the enumeration of [xarr] *)

val sub_enum : 'a t -> int -> int -> 'a Enum.t
(** [sub_enum xarr idx len] returns an enumeration of a subset of [len]
	elements of [xarr], starting with the element at index [idx]. *)

val of_enum : 'a -> 'a Enum.t -> 'a t
(** [of_enum nullval e] returns an t that holds, in order, the 
	elements of [e]. 

	The initial size of the returned xarray is calculated by calling
	[resizer ~currslots:1 ~oldlength:0 ~newlength:(Enum.count e)].
	The default resizer is exponential_resizer.

*)

val insert_enum : 'a t -> int -> 'a Enum.t -> unit
(** [insert_enum xarr idx e] inserts the elements of [e] into [xarr]
	so the first element of [e] has index [idx], the second index [idx]+1,
	etc.   All the elements of [xarr] with index greater than or equal to
	[idx] are moved up by the number of elements in [e] to make room. *)

val set_enum : 'a t -> int -> 'a Enum.t -> unit
(** [set_enum xarr idx e] sets the elements from [e] into [xarr],
	so the first element of [e] has index [idx], etc.  The elements with
	indexs [idx], [idx]+1, etc. are overwritten. *)

(* Reversed enum functions *)

val rev_enum : 'a t -> 'a Enum.t
(** [rev_enum xarr] returns the reverse enumeration of [xarr]- elements are
	enumerated in reverse order- from largest index to smallest. *)

val sub_rev_enum : 'a t -> int -> int -> 'a Enum.t
(** [sub_rev_enum xarr idx len] returns an enumeration of a subset of [len]
	elements of [xarr], starting with the element at index [idx]+[len]-1.
	The elements are returned in reverse order- from highest index to
	lowest index.  So the last element returned from [e] becomes the
	element at index [idx]. *)

val of_rev_enum : 'a -> 'a Enum.t -> 'a t
(** [of_rev_enum nullval e] returns an Xarray.t that holds, in reverse order, 
	the elements of [e].  The first element returned from [e] becomes the
	highest indexed element of the returned Xarray.t, and so on.  Otherwise
	it acts like [of_enum].
*)

val insert_rev_enum : 'a t -> int -> 'a Enum.t -> unit
(** [insert_rev_enum xarr idx e] inserts the elements of [e] into [xarr]
	so the first element of [e] has index [idx]+[len]-1, the second index 
	[idx]+[len]-2, etc, where [len] is the count of elements initially in 
	[e].   The last element from [e] becomes the element at index [idx].  
	Otherwise it acts like [insert_enum].
*)

val set_rev_enum : 'a t -> int -> 'a Enum.t -> unit
(** [set_rev_enum xarr idx e] sets the elements from [e] into [xarr],
	so the first element of [e] has index [idx]+[len]-1, etc, where [len]
	is the count of elements initially in [e].  The last element of [e]
	has index [idx].  Otherwise it acts like [set_enum].
*)

(** {6 Array default resizers} *)

val exponential_resizer : resizer_t
(** The exponential resizer- The default resizer except when the resizer
	is being copied from some other xarray.

	[exponential_resizer] works by doubling or halving the number of
	slots until they "fit".  If the number of slots is less than the
	new length, the number of slots is doubled until it is greater
	than the new length (or Sys.max_array_size is reached).  

	If the number of slots is more than four times the new length,
	the number of slots is halved until it is less than four times the
	new length.

	Allowing xarrays to fall below 25% utilization before shrinking them
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
	only means that xarray is using 4 words per element.  This is
	generally not a signifigant overhead.

	Furthermore, [exponential_resizer] minimizes the number of copies
	needed- appending n elements into an empty xarray with initial size
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

	For example, to make an xarray with a step of 10, a length
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

