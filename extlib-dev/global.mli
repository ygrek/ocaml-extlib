
exception Global_not_initialized of string

type 'a t

(* returns an new named empty global *)
val empty : string -> 'a t

(* retrieve the name of a global *)
val name : 'a t -> string

(* set the global value contents *)
val set : 'a t -> 'a -> unit

(* get the global value contents - raise Global_not_initialized if not defined *)
val get : 'a t -> 'a

(* reset the global value contents to undefined *)
val undef : 'a t -> unit 

(* tell if the global value has been set *)
val isdef : 'a t -> bool 

(* return None if the global is undefined, or Some v where v is the current global value contents *)
val opt : 'a t -> 'a option 
