open ExtLib

exception Empty_list
exception Invalid_index of int

type 'a t = 'a list ref

let empty () = ref []

let isempty x =
	match !x with
	| [] -> true
	| _ -> false

let from_list l = ref l
let to_list rl = !rl
let copy ~dst ~src = dst := !src
let copy_list ~dst ~src = dst := src

let add rl item = rl := ExtList.append !rl [item]
let push rl item = rl := item::!rl

let clear rl = rl := []

let length rl = List.length !rl
let hd rl = try List.hd !rl with _ -> raise Empty_list
let tl rl = try ref (List.tl !rl) with _ -> raise Empty_list
let iter f rl = List.iter f !rl
let for_all f rl = List.for_all f !rl
let map f rl = ref (ExtList.map f !rl)
let map_list f rl = ExtList.map f !rl
let find f rl = List.find f !rl
let rev rl = rl := List.rev !rl
let rev_list rl = List.rev !rl
let find_exc f exn rl = try List.find f !rl with _ -> raise exn
let exists f rl = List.exists f !rl
let sort ?(cmp=compare) rl = rl := List.sort cmp !rl

let rfind f rl = ExtList.rfind f !rl

let first = hd

let last rl = 
	let rec loop = function
		| x :: [] -> x
		| x :: l -> loop l
		| [] -> assert false
	in
	match !rl with
	| [] -> raise Empty_list
	| l -> loop l

let remove rl item = rl := ExtList.remove !rl item
let remove_if pred rl = rl := ExtList.remove_if pred !rl
let remove_all rl item = rl := ExtList.remove_all !rl item
let filter pred rl = rl := List.filter pred !rl

let add_sort ?(cmp=compare) rl item =
	let rec add_aux = function
		| x::lnext as l ->
			let r = cmp x item in
			if r < 0 then item::l else x::(add_aux lnext)
		| [] -> [item]
	in
	rl := add_aux !rl

let pop rl =
	match !rl with
	| [] -> raise Empty_list
	| e::l -> rl := l; e

let npop rl n =		
	let rec pop_aux l n =
		if n = 0 then begin
			rl := l;
			[]
		end else
			match l with
			| [] -> raise Empty_list
			| x::l -> x::(pop_aux l (n-1))
	in
	pop_aux !rl n

let shuffle rl =
	let a = Array.of_list !rl in
	let len = Array.length a in	
	for i = 0 to len-1 do
		let p = (Random.int (len-i))+i in
		let tmp = a.(p) in
		a.(p) <- a.(i);
		a.(i) <- tmp;
	done;
	rl := Array.to_list a

module Index = struct

	let remove_at rl pos =
		let p = ref (-1) in
		let rec del_aux = function			
			| x::l -> incr p; if !p = pos then l else x::(del_aux l)
			| [] -> raise (Invalid_index pos)
		in
		rl := del_aux !rl

	let index pred rl =
		let index = ref (-1) in
		List.find (fun it -> incr index; pred it; ) !rl;
		!index

	let index_of rl item =
		let index = ref (-1) in
		List.find (fun it -> incr index; it = item; ) !rl;
		!index

	let at_index rl pos =
		try
			List.nth !rl pos
		with
			_ -> raise (Invalid_index pos)

	let set rl pos newitem =
		let p = ref (-1) in
		rl := ExtList.map (fun item -> incr p; if !p = pos then newitem else item) !rl;
		if !p < pos || pos < 0 then raise (Invalid_index pos)


end