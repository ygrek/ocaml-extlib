exception Invalid_string

module String = struct

	let ends_with s e =
		let el = String.length e in
		let sl = String.length s in
		if sl < el then
			false
		else
			(String.compare (String.sub s (sl-el) el) e) = 0

	let find str sub =
		let sublen = String.length sub in
		if sublen = 0 then
			0
		else
			let found = ref 0 in
			let len = String.length str in
			try
				for i = 0 to len - sublen do
					let j = ref 0 in
					while str.[i + !j] = sub.[!j] do
						incr j;
						if !j = sublen then begin found := i; raise Exit; end;
					done;
				done;
				raise Invalid_string
			with
				Exit -> !found

	let split str sep =
		let p = find str sep in
		let len = String.length sep in
		let slen = String.length str in
		String.sub str 0 p, String.sub str (p + len) (slen - p - len)

	let lchop s =
		String.sub s 1 ((String.length s)-1)

	let rchop s =
		String.sub s 0 ((String.length s)-1)

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
		let l = String.length s in
		let rec make i =
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
			~clone:(fun () -> make (ref !i))
		in
		make (ref 0)

	let of_enum e =
		let l = Enum.count e in
		let s = String.create l in
		let i = ref 0 in
		Enum.iter (fun c -> s.[!i] <- c; incr i) e;
		s
	
  end
