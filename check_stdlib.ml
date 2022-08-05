(* check compatibility of interfaces *)

#directory "src";;
#load "extLib.cma";;

module XS = (struct
  include ExtLib.String
  external length : string -> int = "%string_length"
  external get : string -> int -> char = "%string_safe_get"
  external set : bytes -> int -> char -> unit = "%string_safe_set"
  external create : int -> bytes = "caml_create_string"
  external unsafe_set : bytes -> int -> char -> unit = "%string_unsafe_set"
  external unsafe_blit : string -> int -> bytes -> int -> int -> unit = "caml_blit_string" [@@noalloc]
  external unsafe_fill : bytes -> int -> int -> char -> unit = "caml_fill_string" [@@noalloc]
end : module type of String)

module XL = (struct
  include ExtLib.List
  let sort = List.sort
end : module type of List)

module XA = (ExtLib.Array : module type of Array)
module XB = (ExtLib.Buffer : module type of Buffer)
module XH = (ExtLib.Hashtbl : module type of Hashtbl)
