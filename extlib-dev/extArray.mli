(** Extra functions defined for arrays *)

(** The wrapper module *)
module Array :
  sig

	val exists: ('a -> bool) -> 'a array -> bool
	(** [exists f x] tests if the predicate [f] is true for at least one element in [x] *)

	val for_all: ('a -> bool) -> 'a array -> bool
	(** [for_all f x] tests if the predicate [f] is true in all elements of [x] *)

	val find: ('a -> bool) -> 'a array -> 'a
	(** [find f x] returns the first element in [x] that satisfies the predicate [f].
	    raises [Not_found] if no such element exists. *)

	val enum : 'a array -> 'a Enum.t
	val of_enum : 'a Enum.t -> 'a array

  end
