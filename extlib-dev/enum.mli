type 'a t

exception No_more_elements

val make : next:(unit -> 'a) -> count:(unit -> int) -> 'a t

val count : 'a t -> int

val has_more : 'a t -> bool

val iter : ('a -> 'b) -> 'a t -> unit

val fold : ('a -> 'b -> 'b) -> 'b -> 'a t -> 'b

val find : ('a -> bool) -> 'a t -> 'a

val force : 'a t -> 'a t

(* Lazy operations, cost O(1) *)

val map : ('a -> 'b) -> 'a t -> 'b t

val filter : ('a -> bool) -> 'a t -> 'a t

val append : 'a t -> 'a t -> 'a t

val concat : unit t t -> unit t