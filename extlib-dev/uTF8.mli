(* $Id: uTF8.mli,v 1.2 2003-06-28 15:53:12 yori Exp $ *)
(* Copyright 2002, 2003 Yamagata Yoriyuki. *)

open UChar

(* UTF-8 encoded string. the type is normal string. *)
type t = string

(* validate s :
 * If s is valid UTF-8 then succeses otherwise raises Malformed_code.
 * Other functions assume strings are valid UTF-8, so it is prudent
 * to test their validity for strings from untrusted origins. *)
exception Malformed_code
val validate : t -> unit

(* All functions below assume string are valid UTF-8.  If not,
 * the result is unspecified. *)

(* get s n : returns [n]-th unicode character of [s].
 * The call requires O(n)-time. *)
val get : t -> int -> uchar

(* init len f : 
 * returns a new string which contains [len] unicode characters.
 * The i-th unicode character is initialized by [f i] *)
val init : int -> (int -> uchar) -> t

(* length s : returns the number of unicode characters contained in s *)
val length : t -> int
    
(* Positions in the string represented by the number of bytes from the head.
 * The location of the fisrt character is [0] *)
type index = int

(* nth s n : returns the potision of the [n]-th unicode character. 
 * The call requires O(n)-time *)
val nth : t -> int -> index

(* last s : The position of the head of the last unicode character. *)
val last : t -> index

(* look s i : 
 * returns the unicode character of the location [i] in the string [s]. *)
val look : t -> index -> uchar

(* out_of_range s i :
 * tests whether [i] points the valid position of [s]. *)
val out_of_range : t -> index -> bool

(* compare_index s i1 i2 : returnes
 * If [i1] is the position located before [i2], a value < 0,
 * If [i1] and [i2] points the same location, 0,
 * If [i1] is the position located after [i2], a value > 0. *)
val compare_index : t -> index -> index -> int

(* next s i : 
 * returnes the position of the head of the unicode character
 * located immediately after [i]. 
 * If [i] is a valid position, the function always success.
 * If [i] is a valid position and there is no unicode character after [i],
 * the position outside [s] is returned.  
 * If [i] is not a valid position, the behavior is undefined. *)
val next : t -> index -> index

(* prev s i : 
 * returnes the position of the head of the unicode character
 * located immediately before [i]. 
 * If [i] is a valid position, the function always success.
 * If [i] is a valid position and there is no unicode character before [i],
 * the position outside [s] is returned.  
 * If [i] is not a valid position, the behavior is undefined. *)
val prev : t -> index -> index

(* move s i n : 
 * If n >= 0, returns [n]-th unicode character after [i].
 * If n < 0, returns [-n]-th unicode character before [i].
 * If there is no such character, the result is unspecified. *)
val move : t -> index -> int -> index
    
(* iter f s :
 * Apply [f] to all unicode characters in [s].  
 * The order of application is same to the order 
 * in the unicode charcters in [s]. *)
val iter : (uchar -> unit) -> t -> unit

(* Code point comparison *)
val compare : t -> t -> int

(* Buffer module for UTF-8 *)
module Buf : sig
  type buf
  (* create n : creates the buffer with the initial size [n]-bytes. *)   
  val create : int -> buf
  (* The rest of functions is similar to the ones of Buffer in stdlib. *)
  val contents : buf -> t
  val clear : buf -> unit
  val reset : buf -> unit
  val add_char : buf -> uchar -> unit
  val add_string : buf -> t -> unit
  val add_buffer : buf -> buf -> unit
end
