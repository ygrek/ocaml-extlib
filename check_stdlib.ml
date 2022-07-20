(* check compatibility of interfaces *)

module XS = (struct
  include ExtLib.String
  external length : string -> int = "%string_length"

  external get : string -> int -> char = "%string_safe_get"

#if OCAML_VERSION < (5, 0, 0)
  external set : bytes -> int -> char -> unit = "%string_safe_set"
  external create : int -> bytes = "caml_create_string"
  external unsafe_set : bytes -> int -> char -> unit = "%string_unsafe_set"
#if OCAML_VERSION < (4, 3, 0)
  external unsafe_fill : bytes -> int -> int -> char -> unit = "caml_fill_string" "noalloc"
#else
  external unsafe_fill : bytes -> int -> int -> char -> unit = "caml_fill_string" [@@noalloc]
#endif
#endif

#if OCAML_VERSION < (4, 3, 0)
  external unsafe_blit : string -> int -> bytes -> int -> int -> unit = "caml_blit_string" "noalloc"
#else
  external unsafe_blit : string -> int -> bytes -> int -> int -> unit = "caml_blit_string" [@@noalloc]
#endif

#if OCAML_VERSION >= (4, 13, 0)
  (* functions with known different signatures *)
  let exists = String.exists
  let starts_with = String.starts_with
  let ends_with = String.ends_with
#endif

end : module type of String)

module XL = (struct
  include ExtLib.List
  let sort = List.sort
end : module type of List)

module XA = (struct
  include ExtLib.Array

#if OCAML_VERSION < (4, 3, 0)
  external make_float : int -> float t = "caml_make_float_vect"
#endif
end: module type of Array)
module XB = (ExtLib.Buffer : module type of Buffer)
module XH = (ExtLib.Hashtbl : module type of Hashtbl)

(* NOTE: needed because dune does not build modules not mentioned in the main module for executables *)
let register () = ()
