exception Invalid_string

module String = struct

	let end_with s e = assert false

	let split s ~sep = assert false

	let chomp s = assert false

	let lchop s = assert false

	let rchop s = assert false

	let of_int = string_of_int

	let of_float = string_of_float

	let of_char = String.make 1

	let to_int s =
		try
			int_of_string s
		with
			_ -> raise Invalid_string

	let to_float s =
		try
			float_of_string s
		with
			_ -> raise Invalid_string

	let enum s =
		let i = ref 0 in
		let l = String.length s in
		Enum.make 
		~next:(fun () ->
			if !i = l then
				raise Enum.No_more_elements
			else
				let p = !i in
				incr i;
				s.[p]
			)
		~count:(fun () -> l - !i)

	let of_enum e =
		let l = Enum.count e in
		let s = String.create l in
		let i = ref 0 in
		Enum.iter (fun c -> s.[!i] <- c; incr i) e;
		s
	
  end
