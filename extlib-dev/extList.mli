(** Extra functions over lists, plus the list functions from the OCaml Standard Library *)
  
module List :
    sig

	exception Empty_list
	exception Invalid_index of int
	exception Different_list_size of string

	val init : int -> (int -> 'a) -> 'a list

	val length : 'a list -> int
	val hd : 'a list -> 'a
	val tl : 'a list -> 'a list
	val nth : 'a list -> int -> 'a
	val first : 'a list -> 'a
	val last : 'a list -> 'a
	val append : 'a list -> 'a list -> 'a list
	val rev_append : 'a list -> 'a list -> 'a list
	val rev : 'a list -> 'a list
	val flatten : 'a list list -> 'a list
	val concat : 'a list list -> 'a list
	val map : ('a -> 'b) -> 'a list -> 'b list
	val mapi : (int -> 'a -> 'b) -> 'a list -> 'b list
	val iteri : (int -> 'a -> 'b) -> 'a list -> unit
	val rev_map : ('a -> 'b) -> 'a list -> 'b list
	val iter : ('a -> unit) -> 'a list -> unit
	val fold : ('b -> 'a -> 'b) -> 'b -> 'a list -> 'b
	val fold_left : ('b -> 'a -> 'b) -> 'b -> 'a list -> 'b
	val fold_right : ('a -> 'b -> 'b) -> 'a list -> 'b -> 'b
	val fast_fold_right : ('a -> 'b -> 'b) -> 'a list -> 'b -> 'b
	val for_all : ('a -> bool) -> 'a list -> bool
	val exists : ('a -> bool) -> 'a list -> bool
	
	val find : ('a -> bool) -> 'a list -> 'a
	val rfind : ('a -> bool) -> 'a list -> 'a
	val find_exc : ('a -> bool) -> exn -> 'a list -> 'a
	val find_all : ('a -> bool) -> 'a list -> 'a list
	val filter : ('a -> bool) -> 'a list -> 'a list
	val filter_map : ('a -> 'b option) -> 'a list -> 'b list
	val partition : ('a -> bool) -> 'a list -> 'a list * 'a list
	
	val split : ('a * 'b) list -> 'a list * 'b list
	val combine : 'a list -> 'b list -> ('a * 'b) list

	val sort : ?cmp:('a -> 'a -> int) -> 'a list -> 'a list
	val split_nth : int -> 'a list -> 'a list * 'a list
	val remove : 'a list -> 'a -> 'a list
	val remove_if : ('a -> bool) -> 'a list -> 'a list
	val remove_all : 'a list -> 'a -> 'a list
	val shuffle : 'a list -> 'a list
	val unique : ?cmp:('a -> 'a -> bool) -> 'a list -> 'a list 

	val mem : 'a -> 'a list -> bool
	val memq : 'a -> 'a list -> bool
	val assoc : 'a -> ('a * 'b) list -> 'b
	val assq : 'a -> ('a * 'b) list -> 'b
	val mem_assoc : 'a -> ('a * 'b) list -> bool
	val mem_assq : 'a -> ('a * 'b) list -> bool
	val remove_assoc : 'a -> ('a * 'b) list -> ('a * 'b) list
	val remove_assq : 'a -> ('a * 'b) list -> ('a * 'b) list

	val map2 : ('a -> 'b -> 'c) -> 'a list -> 'b list -> 'c list
	val iter2 : ('a -> 'b -> unit) -> 'a list -> 'b list -> unit
	val fold_left2 : ('a -> 'b -> 'c -> 'a) -> 'a -> 'b list -> 'c list -> 'a
	val fold_right2 : ('a -> 'b -> 'c -> 'c) -> 'a list -> 'b list -> 'c -> 'c
	val fast_fold_right2 : ('a -> 'b -> 'c -> 'c) -> 'a list -> 'b list -> 'c -> 'c
	val for_all2 : ('a -> 'b -> bool) -> 'a list -> 'b list -> bool
	val exists2 : ('a -> 'b -> bool) -> 'a list -> 'b list -> bool

	val enum : 'a list -> 'a Enum.t
	val of_enum : 'a Enum.t -> 'a list
	val append_enum : 'a list -> 'a Enum.t -> 'a list

end
