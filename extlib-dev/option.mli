exception ValNone

val may : ('a -> unit) -> 'a option -> unit
val map : ('a -> 'b) -> 'a option -> 'b option
val default : 'a -> 'a option -> 'a
val is_some : 'a option -> bool
val is_none : 'a option -> bool
val val_of : 'a option -> 'a (* raise ValNone *)
