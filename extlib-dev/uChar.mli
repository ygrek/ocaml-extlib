(* Copyright 2002, 2003 Yamagata Yoriyuki *)

(* Unicode Characters. All 31bit code points are supported.*)
type t

exception Out_of_range

(* char u : returns the latin-1 representation of [u].
 * If [u] can not be represented by Latin-1, raises Out_of_range *)
val char_of : t -> char

(* char c : returns the Unicode character of the latin-1 character [c] *)
val of_char : char -> t

(* code u : returns the Unicode code number of [u].
 * If the value can not be represented by a positive integer,
 * raise Out_of_range *)
val code : t -> int

(* code n : returns the Unicode charcter with the code number [n]
 * If n exceeded 31-bit value, raises invalid_arg *)
val chr : int -> t

(* uint_code u : returns the Unicode code number of [u].
 * The returned int is unsigned.  that is, on 32-bits platforms,
 * the signed bit is used for storing 31-th bit of the code number. *)
val uint_code : t -> int

(* uint_code n : returns the Unicode character of the code number [n].
 * The [n] is interpreted as unsigned.  that is, on 32-bits platforms,
 * the signed bit is treated as 31-th bit of the code number. *)
val chr_of_uint : int -> t

(* code point comparison. *)
val eq : t -> t -> bool
val compare : t -> t -> int

(* aliases *)
type uchar = t
val int_of_uchar : uchar -> int
val uchar_of_int : int -> uchar
