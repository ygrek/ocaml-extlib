
val unit : 'a -> unit

val input_lines : in_channel -> string Enum.t
val input_chars : in_channel -> char Enum.t

val input_list : in_channel -> string list

val input_all : in_channel -> string

val print_bool : bool -> unit
val prerr_bool : bool -> unit
