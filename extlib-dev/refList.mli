exception Empty_list
exception Invalid_index of int

type 'a t

(* return a new empty ref list *)
val empty : unit -> 'a t

(* tells if a ref list is empty *)
val isempty : 'a t -> bool

(* remove all elements *)
val clear : 'a t -> unit

(* return the number of elements - O(n) *)
val length : 'a t -> int

(* make a copy of a ref list - O(1) *)
val copy : dst:'a t -> src:'a t -> unit

(* make a copy of a list - O(1) *)
val copy_list : dst:'a t -> src:'a list -> unit

(* make a copy of a enum *)
val copy_enum : dst:'a t -> src:'a Enum.t -> unit

(* create a ref list from a list - O(1) *)
val of_list : 'a list -> 'a t

(* return the current elements as a list - O(1) *)
val to_list : 'a t -> 'a list

(* create a ref list from an enumeration *)
val of_enum : 'a Enum.t -> 'a t

(* return an enumeration of current elements in the ref list *)
val enum : 'a t -> 'a Enum.t

(* append the contents of the enumeration to the end of the ref list *)
val append_enum : 'a t -> 'a Enum.t -> unit

(* add an element at the end - O(n) *)
val add : 'a t -> 'a -> unit

(* add an element at the head - O(1) *)
val push : 'a t -> 'a -> unit

(* add an element in a sorted list, using optional comparator
   or 'compare' as default *)
val add_sort : ?cmp:('a -> 'a -> int) -> 'a t -> 'a -> unit

(* return the first element
   raise Empty_list if the ref list is empty *)
val first : 'a t -> 'a

(* return the last element - O(n)
   raise Empty_list if the ref list is empty *)
val last : 'a t -> 'a

(* remove and return the first element
   raise Empty_list if the ref list is empty *)
val pop : 'a t -> 'a

(* remove and return in a list the n first elements
   raise Empty_list if the ref list doed not
   containes enough elements *)
val npop : 'a t -> int -> 'a list

(* same as first *)
val hd : 'a t -> 'a

(* return a ref list containing the same elements
   but without the first one
   raise Empty_list if the ref list is empty *)
val tl : 'a t -> 'a t

(* randomly shuffle the elements 
   using the module Random - O(n^2) *)
val shuffle : 'a t -> unit

(* reverse the ref list *)
val rev : 'a t -> unit

(* return the reversed list *)
val rev_list : 'a t -> 'a list

(** Functional Operations **)

(* apply the given function to all elements of the
   ref list, in respect with the order of the list *)
val iter : ('a -> unit) -> 'a t -> unit

(* find the first element that match
   the specified predicate
   raise Not_found if no element is found *)
val find : ('a -> bool) -> 'a t -> 'a

(* find the first element in the reversed ref list that
   match the specified predicate
   raise Not_found if no element is found *)
val rfind : ('a -> bool) -> 'a t -> 'a

(* same as find but take an exception to be raised when
   no element is found as additional parameter *)
val find_exc : ('a -> bool) -> exn -> 'a t -> 'a

(* tells if an element match the specified
   predicate *)
val exists : ('a -> bool) -> 'a t -> bool

(* tells if all elements are matching the specified
   predicate *)
val for_all : ('a -> bool) -> 'a t -> bool

(* apply a function to all elements
   and return the ref list constructed with
   the function returned values *)
val map : ('a -> 'b) -> 'a t -> 'b t

(* transform all elements in the ref list
   using a function. *)
val transform : ('a -> 'a) -> 'a t -> unit

(* apply a function to all elements
   and return the list constructed with
   the function returned values *)
val map_list : ('a -> 'b) -> 'a t -> 'b list

(* sort elements using the specified comparator
	or compare as default comparator *)
val sort : ?cmp:('a -> 'a -> int) -> 'a t -> unit

(* remove all elements that does not match the
   specified predicate *)
val filter : ('a -> bool) -> 'a t -> unit

(* remove an element from the ref list
   raise Not_found if the element is not found *)
val remove : 'a t -> 'a -> unit

(* remove the first element that does match the
   specified predicate
   raise Not_found if no element have been removed *)
val remove_if : ('a -> bool) -> 'a t -> unit

(* remove all elements equals to the specified
   element from the ref list *)
val remove_all : 'a t -> 'a -> unit


(** Indexed operations are not the appropriate use
	of list (you should use Arrays instead) But it's sometime
	easier to use theses functions. So they've been
	moved in an inner module.
	Indexed functions are O(n) - use arrays for better performances
	*)

module Index : sig

	(* return the index (position : 0 starting) of an element in
	   a ref list, using ( = ) for testing element equality
	   raise Not_found if no element was found *)
	val index_of : 'a t -> 'a -> int

	(* return the index (position : 0 starting) of an element in
	   a ref list, using the specified comparator
	   raise Not_found if no element was found *)
	val index : ('a -> bool) -> 'a t -> int

	(* return the element of ref list at the specified index
	   raise Invalid_index if the index is outside [0 ; length-1] *)
	val at_index : 'a t -> int -> 'a

	(* change the element at the specified index
	   raise Invalid_index if the index is outside [0 ; length-1] *)
	val set : 'a t -> int -> 'a -> unit

	(* remove the element at the specified index
	   raise Invalid_index if the index is outside [0 ; length-1] *)
	val remove_at : 'a t -> int -> unit

end
