(* Copyright 2002, 2003 Yamagata Yoriyuki. *)

type t = int

exception Out_of_range

let char_of c = 
  if c >= 0 && c < 0x100 then Char.chr c else raise Out_of_range

let of_char = Char.code

let code c = if c >= 0 then c else raise Out_of_range

let chr n =
  if n >= 0 && n lsr 31 = 0 then n else invalid_arg "UChar.chr"

let uint_code c = c
let chr_of_uint n = if n lsr 31 = 0 then n else invalid_arg "UChar.uint_chr"
  
let eq (u1 : t) (u2 : t) = u1 = u2
let compare u1 u2 =
  let sgn = (u1 lsr 16) - (u2 lsr 16) in
  if sgn = 0 then (u1 land 0xFFFF) -  (u2 land 0xFFFF) else sgn

type uchar = t

let int_of_uchar u = uint_code u
let uchar_of_int n = chr_of_uint n
