
module Hashtbl :
  sig

	type ('a,'b) t = ('a,'b) Hashtbl.t

	val exists : ('a,'b) t -> bool

	(* return all the keys of an Hashtable
	   if the key is several time in the Hashtable, the list will
	   contain it that many times *)
	val keys : ('a,'b) t -> 'a Enum.t

	(* return all the values of an Hashtable *)
	val values : ('a,'b) t -> 'b Enum.t

	val enum : ('a, 'b) t -> ('a * 'b) Enum.t

	val of_enum : ('a * 'b) Enum.t -> ('a, 'b) t

	(* find a binding for the key, and return a default
	   value if not found *)
	val find_default : ('a,'b) t -> 'a -> 'b -> 'b

	(* remove all bindings for the given key *)
	val remove_all : ('a,'b) t -> 'a -> unit

  end