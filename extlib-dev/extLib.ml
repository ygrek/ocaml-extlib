module ExtList = ExtList.List
module ExtArray = ExtArray.Array
module ExtString = ExtString.String
module ExtHashtbl = ExtHashtbl.Hashtbl

(*TODO*

(* read all the lines of a channel using input_line
   until End_of_file is raised *)
val input_lines : in_channel -> string list

(* return all the data of a channel as a big string *)
val input_all : in_channel -> string

val print_bool : bool -> unit
val prerr_bool : bool -> unit

*)