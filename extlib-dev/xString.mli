exception Invalid_string

module String :
  sig

	(* split the given string among each part of the
	   given separator.
	   raise Invalid_string if the separator is not found *)
	val split : string -> sep:string -> string * string

	(* remove the newline character or the cr-newline (\r\n)
	   characters at the end of the string. return the unmodified
	   string if it doesn't end with \n *)
	val chomp : string -> string

	(* return the same string but without the first character.
	   do nothing if the string is empty *)
	val lchop : string -> string

	(* return the same string but without the last character.
	   do nothing if the string is empty *)
	val rchop : string -> string

	(* return the string representation of an int *)
	val of_int : int -> string

	(* return the string representation of an float *)
	val of_float : float -> string

	(* return a string containing one given character *)
	val of_char : char -> string

	(* return the integer represented by the given string
	   raise Invalid_string if the string does not represent an integer *)
	val to_int : string -> int

	(* return the float represented by the given string
	   raise Invalid_string if the string does not represent a float *)
	val to_float : string -> float

	val enum : string -> char Enum.t
	val of_enum : char Enum.t -> string
	
  end
