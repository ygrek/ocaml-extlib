(** Global variables.

    A Global variable is a pair consisting of a string name and
    a mutable value.
*)

(** {6 Types} *)

exception Global_not_initialized of string
(** Thrown when a global variable is accessed without first having been assigned a value *)

type 'a t
(** The type of globals *)

(** {6 Functions} *)

(** returns an new named empty global *)
val empty : string -> 'a t

(** retrieve the name of a global *)
val name : 'a t -> string

(** set the global value contents *)
val set : 'a t -> 'a -> unit

(** get the global value contents - raise Global_not_initialized if not defined *)
val get : 'a t -> 'a

(** reset the global value contents to undefined *)
val undef : 'a t -> unit 

(** tell if the global value has been set *)
val isdef : 'a t -> bool 

(** return None if the global is undefined, or Some v where v is the current global value contents *)
val opt : 'a t -> 'a option 
