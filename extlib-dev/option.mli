(** Functions to handle option values.

    Options are a variant type defined in Pervasives that can take
    a value of either Some 'a or None.  The functions in this module
    make handling options easier.
*)

exception NoValue

val may : ('a -> unit) -> 'a option -> unit
(** [may f x] will call the function [f] if [x] contains some value. *)

val map : ('a -> 'b) -> 'a option -> 'b option
(** [map f x] will call the function [f] if [x] contains [Some y].
    In this case, it will return [f y], otherwise, it returns None.
*)


val default : 'a -> 'a option -> 'a
(** [default x y] will return the value contained in [y], or will
    return [x] if [y] is None
*)

val is_none : 'a option -> bool
(** [is_none x] test if x=None *)

val is_some : 'a option -> bool
(** [is_some x] returns the opposite of [is_none x] *)

val get : 'a option -> 'a
(** [get x] will get the value inside x.  If x contains None, 
    it will raise NoValue
*)
