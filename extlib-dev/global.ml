exception Global_not_initialized of string

type 'a t = ('a option ref * string)

let empty name = ref None,name

let name = snd

let set (r,_) v = r := Some v

let get (r,name) =
	match !r with
	| None -> raise (Global_not_initialized name)
	| Some v -> v

let undef (r,_) = r := None

let isdef (r,_) = !r = None

let opt (r,_) = !r
