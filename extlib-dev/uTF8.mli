(* $Id: uTF8.mli,v 1.3 2003-07-02 03:00:26 yori Exp $ *)
(* Copyright 2003 Yamagata Yoriyuki. *)

open UChar

(* UTF-8 encoded strings. the type is normal string. *)
type t = string

(* validate s :
 * If s is valid UTF-8 then successes otherwise raises Malformed_code.
 * Other functions assume strings are valid UTF-8, so it is prudent
 * to test their validity for strings from untrusted origins. *)
exception Malformed_code
val validate : t -> unit

(* All functions below assume string are valid UTF-8.  If not,
 * the result is unspecified. *)

(* get s n : returns [n]-th Unicode character of [s].
 * The call requires O(n)-time. *)
val get : t -> int -> uchar

(* init len f : 
 * returns a new string which contains [len] Unicode characters.
 * The i-th Unicode character is initialized by [f i] *)
val init : int -> (int -> uchar) -> t

(* length s : returns the number of Unicode characters contained in s *)
val length : t -> int
    
(* Positions in the string represented by the number of bytes from the head.
 * The location of the first character is [0] *)
type index = int

(* nth s n : returns the position of the [n]-th Unicode character. 
 * The call requires O(n)-time *)
val nth : t -> int -> index

(* last s : The position of the head of the last Unicode character. *)
val last : t -> index

(* look s i : 
 * returns the Unicode character of the location [i] in the string [s]. *)
val look : t -> index -> uchar

(* out_of_range s i :
 * tests whether [i] is the position inside of [s]. *)
val out_of_range : t -> index -> bool

(* compare_index s i1 i2 : returns
 * If [i1] is the position located before [i2], a value < 0,
 * If [i1] and [i2] points the same location, 0,
 * If [i1] is the position located after [i2], a value > 0. *)
val compare_index : t -> index -> index -> int

(* next s i : 
 * returns the position of the head of the Unicode character
 * located immediately after [i]. 
 * If [i] is inside of [s], the function always success.
 * If [i] is inside of [s] and there is no Unicode character after [i],
 * the position outside [s] is returned.  
 * If [i] is not inside of [s], the behaviour is undefined. *)
val next : t -> index -> index

(* prev s i : 
 * returns the position of the head of the Unicode character
 * located immediately before [i]. 
 * If [i] is inside of [s], the function always success.
 * If [i] is inside of [s] and there is no Unicode character before [i],
 * the position outside [s] is returned.  
 * If [i] is not inside of [s], the behaviour is undefined. *)
val prev : t -> index -> index

(* move s i n : 
 * If n >= 0, returns [n]-th Unicode character after [i].
 * If n < 0, returns [n]-th Unicode character before [i].
 * If there is no such character, the result is unspecified. *)
val move : t -> index -> int -> index
    
(* iter f s :
 * Apply [f] to all Unicode characters in [s].  
 * The order of application is same to the order 
 * in the Unicode characters in [s]. *)
val iter : (uchar -> unit) -> t -> unit

(* Code point comparison by the lexicographic order.
 * compare s1 s2 : returns,
 * a positive integer if [s1] > [s2],
 * 0 if [s1] = [s2]
 * a negative integer if [s1] < [s2]. *)
val compare : t -> t -> int

(* Buffer module for UTF-8 *)
module Buf : sig
  (* Buffers for UTF-8 strings. *) 
  type buf
  (* create n : creates the buffer with the initial size [n]-bytes. *)   
  val create : int -> buf
  (* The rest of functions is similar to the ones of Buffer in stdlib. *)
  (* contents buf : returns the contents of the buffer. *)
  val contents : buf -> t
  (* Empty the buffer, but retains the internal storage holding the contents *)
  val clear : buf -> unit
  (* Empty the buffer and de-allocate the internal storage. *)
  val reset : buf -> unit
  (* Add one Unicode character to the buffer. *)
  val add_char : buf -> uchar -> unit
  (* Add a UTF-8 string to the buffer. *)
  val add_string : buf -> t -> unit
  (* add_buffer b1 b2 : adds the contents of [b2] to [b1].
   * the contents of [b2] is not changed. *)
  val add_buffer : buf -> buf -> unit
end
