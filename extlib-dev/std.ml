
let input_enum ch =
	Enum.from (fun () -> try input_line ch with End_of_file -> raise Enum.No_more_elements)

let input_char_enum ch =
	Enum.from (fun () -> try input_char ch with End_of_file -> raise Enum.No_more_elements)

let input_lines ch =
	let rec loop dst =
		let r = [ input_line ch ] in
		Obj.magic (Obj.repr dst) 1 (Obj.repr r);
		loop r
	in
	try
		let r = [ input_line ch ] in
		(try loop r with End_of_file -> ());
		r
	with
		End_of_file -> []


let buf_len = 8192
let static_buf = String.create buf_len

let input_all ch =
	let buf = Buffer.create 0 in
	let rec loop() =
		match input ch static_buf 0 buf_len with
		| 0 -> Buffer.contents buf
		| len ->
			Buffer.add_substring buf static_buf 0 len;
			loop()
	in
	loop()

let print_bool = function
	| true -> print_string "true"
	| false -> print_string "false"

let prerr_bool = function
	| true -> prerr_string "true"
	| false -> prerr_string "false"

