	
module List : sig

	exception Empty_list
	exception Invalid_index of int
	exception Different_list_size of string


	val length : 'a list -> int
	val hd : 'a list -> 'a
	val tl : 'a list -> 'a list
	val nth : 'a list -> int -> 'a
	val duplicate : 'a list -> 'a list * 'a list
	val append : 'a list -> 'a list -> 'a list
	val rev_append : 'a list -> 'a list -> 'a list
	val rev : 'a list -> 'a list
	val flatten : 'a list list -> 'a list
	val concat : 'a list list -> 'a list
	val map : ('a -> 'b) -> 'a list -> 'b list
	val rev_map : ('a -> 'b) -> 'a list -> 'b list
	val iter : ('a -> 'b) -> 'a list -> unit
	val fold_left : ('a -> 'b -> 'a) -> 'a -> 'b list -> 'a
	val fast_fold_right : ('a -> 'b -> 'b) -> 'a list -> 'b -> 'b
	val fold_right : ('a -> 'b -> 'b) -> 'a list -> 'b -> 'b
	val map2 : ('a -> 'b -> 'c) -> 'a list -> 'b list -> 'c list
	val iter2 : ('a -> 'b -> 'c) -> 'a list -> 'b list -> unit
	val fold_left2 : ('a -> 'b -> 'c -> 'a) -> 'a -> 'b list -> 'c list -> 'a
	val fast_fold_right2 : ('a -> 'b -> 'c -> 'c) -> 'a list -> 'b list -> 'c -> 'c
	val fold_right2 : ('a -> 'b -> 'c -> 'c) -> 'a list -> 'b list -> 'c -> 'c
	val for_all : ('a -> bool) -> 'a list -> bool
	val exists : ('a -> bool) -> 'a list -> bool
	val for_all2 : ('a -> 'b -> bool) -> 'a list -> 'b list -> bool
	val exists2 : ('a -> 'b -> bool) -> 'a list -> 'b list -> bool
	val mem : 'a -> 'a list -> bool
	val memq : 'a -> 'a list -> bool
	val assoc : 'a -> ('a * 'b) list -> 'b
	val assq : 'a -> ('a * 'b) list -> 'b
	val mem_assoc : 'a -> ('a * 'b) list -> bool
	val mem_assq : 'a -> ('a * 'b) list -> bool
	val remove_assoc : 'a -> ('a * 'b) list -> ('a * 'b) list
	val remove_assq : 'a -> ('a * 'b) list -> ('a * 'b) list
	val find : ('a -> bool) -> 'a list -> 'a
	val find_all : ('a -> bool) -> 'a list -> 'a list
	val filter : ('a -> bool) -> 'a list -> 'a list
	val partition : ('a -> bool) -> 'a list -> 'a list * 'a list
	val split : ('a * 'b) list -> 'a list * 'b list
	val combine : 'a list -> 'b list -> ('a * 'b) list
	val sort : ?cmp:('a -> 'a -> int) -> 'a list -> 'a list
	val init : int -> (int -> 'a) -> 'a list
	val mapi : (int -> 'a -> 'b) -> 'a list -> 'b list
	val iteri : (int -> 'a -> 'b) -> 'a list -> unit
	val first : 'a list -> 'a
	val last : 'a list -> 'a
	val split_nth : int -> 'a list -> 'a list * 'a list
	val find_exc : ('a -> bool) -> exn -> 'a list -> 'a
	val remove : 'a list -> 'a -> 'a list
	val remove_if : ('a -> bool) -> 'a list -> 'a list
	val remove_all : 'a list -> 'a -> 'a list
	val rfind : ('a -> bool) -> 'a list -> 'a

(*
 * remaining functions to implement (proposals)
 *)

(* -- commented out -- 

 (* tells if the first list is a subset of the second
    using a comparator for elements *)
 val subset : ?cmp:('a -> 'b -> bool) -> 'a list -> 'b list -> bool

 (* return the list where there is no more duplicated
    elements. default comparator is ( = ) *)
 val unique : ?cmp:('a -> 'a -> bool) -> 'a list -> 'a list 

 (* return the list with randomly sorted elements,
    the algorithm result does not depend of the original list
	order, and each list element have the same probabilty to
	be placed at a given position *)
 val shuffle : 'a list -> 'a list

 (* find the last element of the given list that match the
	given predicate *)

---- commented out ends here -- *)

end