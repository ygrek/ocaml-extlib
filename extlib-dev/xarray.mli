
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

type 'a t (* abstract *)
(** The abstract type of a resizable array. *)

val make : ?resizer:(int -> int -> int) -> int -> 'a -> 'a t
(** [make len null] returns an xarray originally capable of holding [len]
    elements, with a null element of [null].  The null element is used to 
    fill unused elements of the underlying array.  

    The optional argument [resizer] can be used to set the resizing 
    behavior- [make ~resiver:foo len null] calls function foo to determine 
    the new size for the underlying array.  The resizer function is called
    with two arguments- the first is the current length of the array, and
    the second is the number of elements used in the array (this can be
    arbitrarily larger than the current number of elements in the array).
    It is called when elements are added to or removed from the array.
    If the returned length is different from the current length of the
    array, a new array of that length will be allocated and the elements
    copied over.  By default the function [exponential_resizer] is used-
    see that function for more details.
*)

val init : ?resizer:(int -> int -> int) -> int -> int -> 'a -> (int -> 'a) -> 'a t
(** [init len used null f] returns an xarray capable of holding [len]
    elements, with a null element of [null].  The null element is used to 
    fill unused elements of the underlying array.  The first [used] elements
    are given values returned by the function [f], with element [idx]
    having the value [f idx].  A resizer function (see [make]) can be
    specified.
 *)

val length : 'a t -> int
(** Return the number of used elements in the xarray- this is effectively
    it's length. *)

val get : 'a t -> int -> 'a
(** [get xarr idx] gets the element in [xarr] at index [idx]. If [xarr] has
    [used] elements in it, then the valid indexs range from [0] to [used-1]. *)

val last : 'a t -> 'a
(** [last xarr] returns the last element of [xarr], or throws 
    [Failure "Xarray.last"] *)

val set : 'a t -> int -> 'a -> unit
(** [set xarr idx v] sets the element of [xarr] at index [idx] to value
    [v].  The previous value is overwritten.  If [idx] is equal to
    [used xarr] (i.e. the index is one past the end of the xarray), the
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
    equivelent to going [delete xarr ((used xarr) - 1)]. *)

val blit : 'a t -> int -> 'a t -> int -> int -> unit
(** [blit src srcidx dst dstidx len] copies [len] elements from [src]
    starting with index [srcidx] to [dst] starting at [dstidx].  The
    sub-xarrays can be in the same xarray, and even overlap.  This is a
    fast way to move blocks of elements around.
 *)

val to_list : 'a t -> 'a list
(** [to_list xarr] returns the elements of [xarr] in order as a list. *)

val to_array : 'a t -> 'a array
(** [to_array xarr] returns the elements of [xarr] in order as an array. *)

val of_list : ?resizer:(int -> int -> int) -> 'a -> 'a list -> 'a t
(** [of_list null lst] returns an xarray with the elements of [lst] in it
    in order, and [null] as it's null element.  A resizing strategy can
    be specified- the default is to use [exponential_resizer]. *)

val of_array : ?resizer:(int -> int -> int) -> 'a -> 'a array -> 'a t
(** [of_array null arr] returns an xarray with the elements of [arr] in it
    in order, and [null] as it's null element.  A resizing strategy can
    be specified- the default is to use [exponential_resizer]. *)

val copy : ?resizer:(int -> int -> int) -> 'a t -> 'a t
(** [copy src] returns a fresh copy of [src], such that no modification of
    [src] affects the copy, or vice versa (all new memory is allocated for
    the copy).  A new resizing strategy can be specified- if no resizing
    strategy is specified, the copy uses the same function as [src]. *)

val sub : ?resizer:(int -> int -> int) -> 'a t -> int -> int -> 'a t
(** [sub xarr start len] returns an xarray holding the subset of [len] 
    elements from [xarr] starting with the element at index [idx].  A
    new resizing strategy can be provided- if no strategy is provided,
    the strategy of [xarr] is used.  The initial size of the returned
    xarray is calculated by calling it's resize strategy, starting with
    the current length of the underlying array of [xarr] and [len].
 *)

val iter : ('a -> unit) -> 'a t -> unit
(** [iter f xarr] calls the function [f] on every element of [xarr].  It
    is equivelent to for i = 0 to ([used xarr]) do f ([get xarr i]) done; *)

val iteri : (int -> 'a -> unit) -> 'a t -> unit
(** [iter f xarr] calls the function [f] on every element of [xarr].  It
    is equivelent to for i = 0 to ([used xarr]) do f i ([get xarr i]) done; *)

val map : ?resizer:(int -> int -> int) -> ('a -> 'b) -> 'b -> 'a t -> 'b t
(** [map f nulldst xarr] applies the function [f] to every element of [xarr]
    and creates an xarray from the results- similiar to [List.map] or
    [Array.map].  [nulldst] is the null element of the returned xarray.
    A resize strategy for the returned xarray can be specified.  If none is 
    specified the resize strategy of [xarr] is used. *)

val mapi : ?resizer:(int -> int -> int) -> (int -> 'a -> 'b) -> 'b -> 'a t -> 'b t
(** [mapi f nulldst xarr] applies the function [f] to every element of [xarr]
    and creates an xarray from the results- similiar to [List.mapi] or
    [Array.mapi].  [nulldst] is the null element of the returned xarray.
    A resize strategy for the returned xarray can be specified.  If none is 
    specified the resize strategy of [xarr] is used. *)

val fold_left : ('a -> 'b -> 'a) -> 'a -> 'b t -> 'a
(** [fold_left f x xarr] computes 
    [f ( ... ( f ( f (get xarr 0) x) (get xarr 1) ) ... ) (get xarr n-1)],
    similiar to [Array.fold_left] or [List.fold_left]. *)

val fold_right : ('a -> 'b -> 'b) -> 'a t -> 'b -> 'b
(** [fold_right f xarr x] computes
    [ f (get xarr 0) (f (get xarr 1) ( ... ( f (get xarr n-1) x ) ... ) ) ]
    similiar to [Array.fold_right] or [List.fold_right]. *)

val enum : 'a t -> 'a Enum.t
(** [enum xarr] returns the enumeration of [xarr] *)

val sub_enum : 'a t -> int -> int -> 'a Enum.t
(** [sub_enum xarr idx len] returns an enumeration of a subset of [len]
    elements of [xarr], starting with the element at index [idx]. *)

val of_enum : ?resizer:(int -> int -> int) -> 'a -> 'a Enum.t -> 'a t
(** [of_enum nullval e] returns an t that holds, in order, the 
    elements of [e]. *)

val insert_enum : 'a t -> int -> 'a Enum.t -> unit
(** [insert_enum xarr idx e] inserts the elements of [e] into [xarr]
    so the first element of [e] has index [idx], the second index [idx]+1,
    etc.   All the elements of [xarr] with index greater than or equal to
    [idx] are moved up by the number of elements in [e] to make room. *)

val set_enum : 'a t -> int -> 'a Enum.t -> unit
(** [set_enum xarr idx e] sets the elements from [e] into [xarr],
    so the first element of [e] has index [idx], etc.  The elements with
    indexs [idx], [idx]+1, etc. are overwritten. *)

val exponential_resizer : int -> int -> int
(** The exponential resizer- [exponential_resizer curr used] returns the
    array length required to hold [used] items- generally some function of
    [curr].
   
    If [used] is greater than [curr], [exponential_resizer] doubles [curr]
    until it is greater (or the maximum array length is reached).  If [used]
    is less than one quarter of [curr], [exponential_resizer] halves the
    [curr] until [used] is greater than one quarter.  Note that the one
    quarter limit is necessary to prevent thrashing (where adding and removing
    a small number of items causes the array to be continually reallocated).
 *)

val step_resizer : int -> int -> int -> int
(** The stepwise resizer- [step_resizer step curr used] returns the
    array length required to hold [used] items- a function of [curr] and
    [step].
   
    The function [step_resizer] returns the smallest multiple of [step]
    larger than [used] if [curr] is less then [used]-[step] or greater than
    [used].

    This function generally needs to be partially applied to use it as
    a resizer.  For example, to make an xarray with a step of 10, a length
    of len, and a null of null, you would do:
    [make] ~resizer:([step_resizer] 10) len null
 *)


