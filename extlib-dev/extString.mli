exception Invalid_string

module String :
  sig

	val ends_with : string -> string -> bool

	(* [find s x] return the starting index of the string [x]
	   within the string [s] or raise Invalid_string if [x]
	   is not a substring of [s]. *)
	val find : string -> string -> int

	(* split the given string among each part of the
	   given separator.
	   raise Invalid_string if the separator is not found *)
	val split : string -> string -> string * string

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
