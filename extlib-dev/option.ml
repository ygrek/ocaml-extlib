exception NoValue

let may f = function
	| None -> ()
	| Some v -> f v

let map f = function
	| None -> None
	| Some v -> Some (f v)

let default v = function
	| None -> v
	| Some v -> v

let is_some = function
	| None -> false
	| _ -> true

let is_none = function
	| None -> true
	| _ -> false

let get = function
	| None -> raise NoValue
	| Some v -> v
