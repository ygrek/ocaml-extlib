
(* ExtList, a tail recursion only implementation of the OCaml list library.
 * Copyright (C) 2003 Brian Hurt
 * 
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 * 03-15-03 : Modified by Nicolas Cannasse , added functions
 *)

module List = struct

exception Empty_list
exception Invalid_index of int
exception Different_list_size of string

(* Inner functions prefixed with _ *)
let _setcdr : 'a list -> 'a list -> unit = fun c v -> 
    Obj.set_field (Obj.repr c) 1 (Obj.repr v)

let _duplicate = function
    | [] -> assert false
    | h :: t ->
		let rec loop dst = function
			| [] -> dst
			| h :: t -> 
				let r = [ h ] in
				_setcdr dst r;
				loop r t
		in
        let r = [ h ] in
        r, loop r t


let length l =
	let rec loop len = function
		| [] -> len
		| h :: t -> loop (len + 1) t
    in
	loop 0 l

let hd = function
    | [] -> raise Empty_list
    | h :: t -> h

let tl = function
    | [] -> raise Empty_list
    | h :: t -> t

let nth l index =
	if index < 0 then raise (Invalid_index index);
	let rec loop n = function
		| [] -> raise (Invalid_index index);
		| h :: t -> 
			if (n = 0) then h else loop (n - 1) t
	in
	loop index l

let append l1 l2 =
	match l1 with
	| [] -> l2
	| h :: t ->
		let rec loop accu = function
		| [] -> _setcdr accu l2
		| h :: t ->
			let cell = [h] in
			_setcdr accu cell;
			loop cell t
		in
		let r = [h] in
		loop r t;
		r

let rec rev_append l1 l2 =
    match l1 with
    | [] -> l2
    | h :: t -> rev_append t (h :: l2)

let rev l = rev_append l []

let flatten = function
    | [] -> []
    | h :: t ->
		let rec loop dst = function
			| [] -> ()
			| h :: t ->
			   let a, b = _duplicate h in
			   _setcdr dst a;
			   loop b t
		in
        let a, b = _duplicate h in
        loop b t;
        a

let concat = flatten

let map f = function
	| [] -> []
	| h :: t ->
		let rec loop dst = function
		| [] -> ()
		| h :: t ->
			let r = [f h] in
			_setcdr dst r;
			loop r t
		in
		let r = [f h] in
		loop r t;
		r

let rev_map f l =
    let rec loop accum = function
        | [] -> accum
        | h :: t -> loop ((f h) :: accum) t
    in
    loop [] l

let rec iter f = function
    | [] -> ()
    | h :: t -> f h; iter f t

let rec fold_left f accum = function
    | [] -> accum
    | h :: t -> fold_left f (f accum h) t

let fold_right f l accum =
    let rec loop accum = function
        | [] -> accum
        | h :: t -> loop (f h accum) t
    in
    loop accum (rev l)

let rec fast_fold_right f l accum =
    match l with
    | [] -> accum
    | h :: t -> f h (fast_fold_right f t accum)

let map2 f l1 l2 =
    match l1, l2 with
    | [], [] -> []
    | h1 :: t1, h2 :: t2 ->
		let rec loop dst src1 src2 =
			match src1, src2 with
			| [], [] -> ()
			| h1 :: t1, h2 :: t2 ->
				let r = [ f h1 h2 ] in
				_setcdr dst r;
				loop r t1 t2
			| _ -> raise (Different_list_size "map2")
		in
		let r = [ f h1 h2 ] in
        loop r t1 t2;
        r
    | _ -> raise (Different_list_size "map2")

let rec iter2 f l1 l2 =
    match l1, l2 with
    | [], [] -> ()
    | h1 :: t1, h2 :: t2 -> f h1 h2; iter2 f t1 t2
    | _ -> raise (Different_list_size "iter2")

let rec fold_left2 f accum l1 l2 =
    match l1, l2 with
    | [], [] -> accum
    | h1 :: t1, h2 :: t2 -> fold_left2 f (f accum h1 h2) t1 t2
    | _ -> raise (Different_list_size "fold_left2")

let fold_right2 f l1 l2 accum =
    let rec loop l1 l2 accum =
        match l1, l2 with
        | [], [] -> accum
        | h1 :: t1, h2 :: t2 -> loop t1 t2 (f h1 h2 accum)
        | _ -> raise (Different_list_size "fold_right2")
    in
    loop (rev l1) (rev l2) accum

let rec fast_fold_right2 f l1 l2 accum =
    match l1, l2 with
    | [], [] -> accum
    | h1 :: t1, h2 :: t2 -> f h1 h2 (fast_fold_right2 f t1 t2 accum)
    | _ -> raise (Different_list_size "fast_fold_right2")

let for_all p l =
    let rec loop = function
        | [] -> true
        | h :: t -> if p h then loop t else false
    in
    loop l

let exists p l =
    let rec loop = function
        | [] -> false
        | h :: t -> if p h then true else loop t
    in
    loop l

let for_all2 p l1 l2 =
    let rec loop l1 l2 =
        match l1, l2 with
        | [], [] -> true
        | h1 :: t1, h2 :: t2 -> if p h1 h2 then loop t1 t2 else false
        | _ -> raise (Different_list_size "for_all2")
    in
    loop l1 l2

let exists2 p l1 l2 =
    let rec loop l1 l2 =
        match l1, l2 with
            | [], [] -> false
            | h1 :: t1, h2 :: t2 -> if p h1 h2 then true else loop t1 t2
            | _ -> raise (Different_list_size "exists2")
    in
    loop l1 l2

let rec mem x = function
    | [] -> false
    | h :: t -> if h = x then true else mem x t

let rec memq x = function
    | [] -> false
    | h :: t -> if h == x then true else memq x t

let rec assoc x = function
    | [] -> raise Not_found
    | (a, b) :: t -> if a = x then b else assoc x t

let rec assq x = function
    | [] -> raise Not_found
    | (a, b) :: t -> if a == x then b else assq x t

let rec mem_assoc x = function
    | [] -> false
    | (a, b) :: t -> if a = x then true else mem_assoc x t

let rec mem_assq x = function
    | [] -> false
    | (a, b) :: t -> if (a == x) then true else mem_assq x t

let remove_assoc x = function
    | [] -> []
    | (a, _ as pair) :: t ->
		let rec loop dst = function
			| [] -> ()
			| (a, _ as pair) :: t -> 
				if a = x then
					_setcdr dst t
				else
					let r = [ pair ] in
					_setcdr dst r;
					loop r t
		in
		if a = x then
			t
		else
			let r = [ pair ] in
			loop r t;
			r

let remove_assq x = function
    | [] -> []
    | (a, _ as pair) :: t ->
		let rec loop dst = function
			| [] -> ()
			| (a, _ as pair) :: t -> 
				if a == x then
					_setcdr dst t
				else
					let r = [ pair ] in
					_setcdr dst r;
					loop r t
		in
		if a == x then
            t
        else
			let r = [ pair ] in
			loop r t;
			r

let rec find p = function
   | [] -> raise Not_found
   | h :: t -> if p h then h else find p t

let rfind p l = find p (List.rev l)

let find_all p l = 
    let rec findfirst = function
        | [] -> []
        | h :: t ->
            if p h then
                let r = [ h ] in
				let rec findnext dst = function
					| [] -> ()
					| h :: t -> 
						if p h then
							let r = [ h ] in
							_setcdr dst r;
							findnext r t
						else
							findnext dst t
				in
                findnext r t;
                r
            else
                findfirst t
    in
    findfirst l

let filter = find_all

let partition p = function
    | [] -> [], []
    | h :: t ->
		let rec both yesdst nodst = function
			| [] -> ()
			| h :: t ->
				let r = [ h ] in
				if p h then begin
					_setcdr yesdst r;
					both r nodst t
				end else begin
					_setcdr nodst r;
					both yesdst r t
				end
		in
		let rec yesonly yesdst = function
			| [] -> []
			| h :: t ->
				let r = [ h ] in
				if p h then begin
					_setcdr yesdst r;
					yesonly r t
				end else begin
					both yesdst r t;
					r
				end
		in 
		let rec noonly nodst = function
			| [] -> []
			| h :: t ->
				let r = [ h ] in
				if p h then begin
					both r nodst t;
					r
				end else begin
					_setcdr nodst r;
					noonly r t
				end
		in
        let r = [ h ] in
        if p h then
            (r, (yesonly r t))
        else
            ((noonly r t), r)

let split = function
    | [] -> [], []
    | (a, b) :: t ->
		let rec loop adst bdst = function
			| [] -> ()
			| (a, b) :: t -> 
				let x = [ a ] and y = [ b ] in
				_setcdr adst x;
				_setcdr bdst y;
				loop x y t
		in
        let x = [ a ] and y = [ b ] in
        loop x y t;
        x, y

let combine l1 l2 =
    match l1, l2 with
    | [], [] -> []
    | h1 :: t1, h2 :: t2 ->
		let rec loop dst l1 l2 =
			match l1, l2 with
			| [], [] -> ()
			| h1 :: t1, h2 :: t2 -> 
				let r = [ h1, h2 ] in
				_setcdr dst r;
				loop r t1 t2
			| _, _ -> raise (Different_list_size "combine")
		in
        let r = [ h1, h2 ] in
		loop r t1 t2;
        r
    | _, _ -> raise (Different_list_size "combine")

let sort ?(cmp=compare) = List.sort cmp

(* 
 * Additionnal functions
 * added 03-15-03 by Nicolas Cannasse
 *)

let rec init size f =
	if size = 0 then [] 
	else if size < 0 then invalid_arg "ExtList.init"
	else
		let rec loop dst n =
			if n < size then
				let r = [ f n ] in
				_setcdr dst r;
				loop r (n+1)
		in
		let r = [ f 0 ] in
		loop r 1;
		r

let mapi f = function
    | [] -> []
    | h :: t ->
		let rec loop dst n = function
			| [] -> ()
			| h :: t -> 
				let r = [ f n h ] in
				_setcdr dst r;
				loop r (n+1) t
		in	
        let r = [ f 0 h ] in
        loop r 1 t;
        r

let iteri f l = 
	let rec loop n = function
		| [] -> ()
		| h :: t ->
			f n h;
			loop (n+1) t
	in
	loop 0 l

let first = hd

let rec last = function
	| [] -> raise Empty_list
	| h :: [] -> h
	| _ :: t -> last t

let split_nth index = function
	| [] -> if index = 0 then [],[] else raise (Invalid_index index)
	| (h :: t as l) ->
		if index = 0 then [],l
		else if index < 0 then raise (Invalid_index index)
		else
			let rec loop n dst l =
				if n = 0 then l else
				match l with
				| [] -> raise (Invalid_index index)
				| h :: t ->
					let r = [ h ] in
					_setcdr dst r;
					loop (n-1) r t 
			in
			let r = [ h ] in
			r, loop (index-1) r t

let find_exc f e l =
	try
		find f l
	with
		Not_found -> raise e

let remove l x =
	match l with
	| [] -> raise Not_found
	| h :: t ->
		if x = h then t
		else
			let rec loop dst = function
				| [] -> raise Not_found
				| h :: t ->
					if x = h then 
						_setcdr dst t
					else
						let r = [ h ] in
						_setcdr dst r;
						loop r t
			in
			let r = [ h ] in
			loop r t;
			r

let rec remove_if f = function
	| x::l when (f x) -> l
	| x::l -> x::(remove_if f l)
	| [] -> raise Not_found

let rec remove_all l x =
	match l with
	| [] -> []
	| h :: t ->
		if x = h then remove_all t x
		else
			let rec loop dst = function
				| [] -> ()
				| h :: t ->
					if x = h then
						loop dst t
					else
						let r = [ h ] in
						_setcdr dst r;
						loop r t
			in
			let r = [ h ] in
			loop r t;
			r
let shuffle l =
	let a = Array.of_list l in
	let len = Array.length a in	
	for i = 0 to len-1 do
		let p = (Random.int (len-i))+i in
		let tmp = a.(p) in
		a.(p) <- a.(i);
		a.(i) <- tmp;
	done;
	Array.to_list a

(* Added functions for Enum support
	- 2003-04-15, Nicolas Cannasse *)

let enum l =
	let lr = ref l in
	Enum.make
		~next:(fun () ->
			match !lr with
			| [] -> raise Enum.No_more_elements
			| h :: t ->
				lr := t;
				h
		)
		~count:(fun () ->
			length !lr
		)

let of_enum e =
	let dum = [ Obj.magic () ] in
	let _ = Enum.fold (fun x acc ->
		let r = [ x ] in
		_setcdr acc r;
		r) dum e in
	tl dum

let append_enum l e =
	append l (of_enum e)

end
