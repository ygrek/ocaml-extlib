(** Extra functions over hashtables. *)

module Hashtbl :
  (** The wrapper module *)
  sig

	type ('a,'b) t
	(** The type of a hashtable. *)

	val exists : ('a,'b) t -> bool

	val keys : ('a,'b) t -> 'a Enum.t
	(** return all the keys of an Hashtable.
	    If the key is in the Hashtable multiple times, all occuraces
	    will be returned  *)

	val values : ('a,'b) t -> 'b Enum.t
	(** return all the values Hashtable *)

	val enum : ('a, 'b) t -> ('a * 'b) Enum.t

	val of_enum : ('a * 'b) Enum.t -> ('a, 'b) t

	val find_default : ('a,'b) t -> 'a -> 'b -> 'b
	(** find a binding for the key, and return a default
	    value if not found *)

	val remove_all : ('a,'b) t -> 'a -> unit
	(** remove all bindings for the given key *)

	val map : ('b -> 'c) -> ('a,'b) t -> ('a,'c) t
	(** [map f x] creates a new hashtable with the same
	    keys as [x], but with the function [f] applied to
	    all the values *)
  end
