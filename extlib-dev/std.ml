
let lines_enum ch =
    let dummy = ref None in
    let e = Enum.make 
        ~next:(fun () -> try input_line ch with End_of_file -> raise Enum.No_more_elements)
        ~count:(fun () -> match !dummy with None -> assert false | Some e -> Enum.force e; Enum.count e)
    in
    dummy := Some e;
    e


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


let input_all ch =
	assert false (* TODO *)

let print_bool = function
	| true -> print_string "true"
	| false -> print_string "false"

let prerr_bool = function
	| true -> prerr_string "true"
	| false -> prerr_string "false"

