
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

(* Thanks to Olivier Andrieu <andrieu@ijm.jussieu.fr> for this routine.
 * DO NOT USE IT unless you really know what you're doing.
 *)
let setcdr : 'a list -> 'a list -> unit = fun c v -> 
    Obj.set_field (Obj.repr c) 1 (Obj.repr v)

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
	let rec loop n = function
		| [] -> raise (Invalid_index index);
		| h :: t -> 
			if (n = 0) then h else loop (n - 1) t
	in
	if index < 0 then raise (Invalid_index index);
	loop index l


let duplicate = 
	let rec loop dst = function
		| [] -> dst
		| h :: t -> 
			let r = [ h ] in
			setcdr dst r;
			loop r t
	in
	function
    | [] -> assert false
    | h :: t ->
        let r = [ h ] in
        r, loop r t

let append l1 l2 = 
    match l1 with
    | [] -> l2
    | _ -> 
        let r, tl = duplicate l1 in
        setcdr tl l2;
        r

let rec rev_append l1 l2 =
    match l1 with
    | [] -> l2
    | h :: t -> rev_append t (h :: l2)

let rev l = rev_append l []

let flatten = 
	let rec loop dst = function
		| [] -> ()
		| h :: t ->
		   let a, b = duplicate h in
		   setcdr dst a;
		   loop b t
	in
	function
    | [] -> []
    | h :: t ->
        let a, b = duplicate h in
        loop b t;
        a

let concat = flatten

let map f = 
	let rec loop dst = function
		| [] -> ()
		| h :: t -> 
			let r = [ f h ] in
			setcdr dst r;
			loop r t
	in function
    | [] -> []
    | h :: t -> 
        let r = [ f h ] in
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
    | h :: t -> f h (fold_right f t accum)

let map2 f l1 l2 =
    let rec loop dst src1 src2 =
        match src1, src2 with
        | [], [] -> ()
        | h1 :: t1, h2 :: t2 ->
            let r = [ f h1 h2 ] in
            setcdr dst r;
            loop r t1 t2
        | _ -> raise (Different_list_size "map2")
    in
    match l1, l2 with
    | [], [] -> []
    | h1 :: t1, h2 :: t2 ->
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
    | h1 :: t1, h2 :: t2 -> f h1 h2 (fold_right2 f t1 t2 accum)
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

let remove_assoc x =
    let rec loop dst = function
        | [] -> ()
		| (a, _ as pair) :: t -> 
            if a = x then
                setcdr dst t
            else
				let r = [ pair ] in
				setcdr dst r;
				loop r t
    in
    function
    | [] -> []
    | (a, _ as pair) :: t ->
		if a = x then
			t
		else
			let r = [ pair ] in
			loop r t;
			r

let remove_assq x =
    let rec loop dst = function
        | [] -> ()
        | (a, _ as pair) :: t -> 
            if a == x then
                setcdr dst t
            else
				let r = [ pair ] in
				setcdr dst r;
				loop r t
    in
    function
    | [] -> []
    | (a, _ as pair) :: t ->
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
    let rec findnext dst = function
        | [] -> ()
        | h :: t -> 
            if p h then
                let r = [ h ] in
                setcdr dst r;
                findnext r t
            else
                findnext dst t
    in
    let rec findfirst = function
        | [] -> []
        | h :: t ->
            if p h then
                let r = [ h ] in
                findnext r t;
                r
            else
                findfirst t
    in
    findfirst l

let filter = find_all

let partition p =
    let rec both yesdst nodst = function
        | [] -> ()
        | h :: t ->
            let r = [ h ] in
            if p h then begin
                setcdr yesdst r;
                both r nodst t
            end else begin
                setcdr nodst r;
                both yesdst r t
            end
    in
    let rec yesonly yesdst = function
        | [] -> []
        | h :: t ->
            let r = [ h ] in
            if p h then begin
                setcdr yesdst r;
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
                setcdr nodst r;
                noonly r t
            end
    in
    function
    | [] -> [], []
    | h :: t ->
        let r = [ h ] in
        if p h then
            (r, (yesonly r t))
        else
            ((noonly r t), r)

let split = 
	let rec loop adst bdst = function
		| [] -> ()
		| (a, b) :: t -> 
			let x = [ a ] and y = [ b ] in
			setcdr adst x;
			setcdr bdst y;
			loop x y t
	in
	function
    | [] -> [], []
    | (a, b) :: t ->
        let x = [ a ] and y = [ b ] in
        loop x y t;
        x, y

let combine l1 l2 =
    let rec loop dst l1 l2 =
        match l1, l2 with
        | [], [] -> ()
        | h1 :: t1, h2 :: t2 -> 
            let r = [ h1, h2 ] in
            setcdr dst r;
            loop r t1 t2
        | _, _ -> raise (Different_list_size "combine")
    in
    match l1, l2 with
    | [], [] -> []
    | h1 :: t1, h2 :: t2 ->
        let r = [ h1, h2 ] in
		loop r t1 t2;
        r
    | _, _ -> raise (Different_list_size "combine")

(* Note that unlike the standard sort, I don't do direct sorting on three-
 * element lists.  On the other hand, I don't have to reverse my lists
 * either, so I probably win.
 *)
let rec sort ?(cmp=compare) =
    let rec splitloop dst1 dst2 lst =
        match lst with
        | [] -> ()
        | a :: [] -> setcdr dst1 [ a ]
        | a :: b :: t ->
            let x = [ a ] and y = [ b ] in
            setcdr dst1 x;
            setcdr dst2 y;
            splitloop x y t
    in
    let rec combineloop dst lst1 lst2 =
        match lst1, lst2 with
        | [], [] -> ()
        | [], _ -> setcdr dst lst2
        | _, [] -> setcdr dst lst1
        | h1 :: t1, h2 :: t2 ->
            if (cmp h1 h2) <= 0 then begin
                let r = [ h1 ] in
                setcdr dst r;
                combineloop r t1 lst2
            end else begin
                let r = [ h2 ] in
                setcdr dst r ;
                combineloop r lst1 t2
            end
    in
    let combine l1 l2 =
       match l1, l2 with
       | [], [] -> []
       | [], _ -> l2
       | _, [] -> l1
       | h1 :: t1, h2 :: t2 ->
           if (cmp h1 h2) <= 0 then begin
               let r = [ h1 ] in
               combineloop r t1 l2;
               r
           end else begin
               let r = [ h2 ] in
               combineloop r l1 t2;
               r
           end
    in
    function
    | [] -> []
    | (a :: []) as l -> l
    | a :: b :: t ->
        let x = [ a ] and y = [ b ] in
        splitloop x y t;
        combine (sort ~cmp x) (sort ~cmp y)

(* 
 * Additionnal functions
 * added 03-15-03 by Nicolas Cannasse
 *)

let rec init size f =
	let rec loop dst n =
		if n < size then
			let h = [ f n ] in
			setcdr dst h;
			loop h (n+1)
	in
	if size = 0 then [] 
	else if size < 0 then invalid_arg "ExtList.init"
	else
		let h = [ f 0 ] in
		loop h 1;
		h

let mapi f = 
	let rec loop dst n = function
		| [] -> ()
		| h :: t -> 
			let r = [ f n h ] in
			setcdr dst r;
			loop r (n+1) t
	in function
    | [] -> []
    | h :: t -> 
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

let split_nth index =
	let rec loop n dst l =
		if n = 0 then l else
		match l with
		| [] -> raise (Invalid_index index)
		| h :: t ->
			let r = [ h ] in
			setcdr dst r;
			loop (n-1) r t 
	in
	function
	| [] -> if index = 0 then [],[] else raise (Invalid_index index)
	| (h :: t as l) ->
		if index = 0 then [],l
		else if index < 0 then raise (Invalid_index index)
		else
			let r = [ h ] in
			r, loop (index-1) r t

let find_exc f e l =
	try
		find f l
	with
		Not_found -> raise e

let remove l x =
	let rec loop dst = function
		| [] -> raise Not_found
		| h :: t ->
			if x = h then Obj.set_field (Obj.repr dst) 1 (Obj.repr t)
			else
				let r = [ h ] in
				Obj.set_field (Obj.repr dst) 1 (Obj.repr r);
				loop r t
	in
	match l with
	| [] -> raise Not_found
	| h :: t ->
		if x = h then t
		else
			let r = [ h ] in
			loop r t;
			r

let rec remove_if f = function
	| x::l when (f x) -> l
	| x::l -> x::(remove_if f l)
	| [] -> raise Not_found


let rec remove_all l x =
	let rec loop dst = function
		| [] -> ()
		| h :: t ->
			if x = h then
				loop dst t
			else
				let r = [ h ] in
				Obj.set_field (Obj.repr dst) 1 (Obj.repr r);
				loop r t
	in
	match l with
	| [] -> []
	| h :: t ->
		if x = h then remove_all t x
		else
			let r = [ h ] in
			loop r t;
			r

end
