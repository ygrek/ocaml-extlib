(* 
 * IO - Abstract input/output
 * Copyright (C) 2003 Nicolas Cannasse
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version,
 * with the special exception on linking described in file LICENSE.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *)

(** High-order abstract I/O.

	IO module simply deals with abstract inputs/outputs. It provides a
	set of methods for working with these IO as well as several
	constructors that enable to write to an underlying channel, buffer,
	or enum. 

	Each input and output can read/write two kinds of tokens: single 
	token (such as a [char]) and token-buffer (such as a [string]).
	A single token has a size of 1 and a token-buffer has a variable
	size. The size of a token-buffer can be fully determined by itself 
	(for example, the size of the string can be determined using the
	[String.length] function on itself).
*)

type ('a, 'b) input
(** The abstract input type, ['a] is the type for the single-token which
  can be read using the [read] function, ['b] is the type for the 
  token-buffer which can be read using the [nread] function. *)

type ('a, 'b, 'c) output
(** The abstract output type, ['a] is the type for the single-token which
  can be written using the [write] function, ['b] is the type for the
  token-buffer which can be written using the [nwrite] function.
  ['c] is the accumulator data, it is returned when the [close_out]
  function is called. *)

type stdin = (char, string) input
(** A standard input can read [char] and [string]. *)

type 'a stdout = (char, string,'a) output
(** A standard ouput can write [char] and [string]. *)

exception No_more_input
(** This exception is raised when reading on an input with the [read] or
  [nread] functions while there is no available token to read. *)

exception Input_closed
(** This exception is raised when reading on a closed input. *)

exception Output_closed
(** This exception is raised when reading on a closed output. *)

exception Not_implemented
(** This exception is raised when using [available] [pos_in] or [pos_out]
  on a IO that does not support them. *)

(** {6 Standard API} *)

val read : ('a, 'b) input -> 'a
(** Read a single token from an input or raise [No_more_input] if
  no token available. *)

val nread : ('a, 'b) input -> int -> 'b
(** [nread i n] reads a token-buffer of size up to [n] from an input.
  The function will raise No_more_input if no token is available and
  if [n] > 0. It will raise [Invalid_argument] is [n] < 0. *)

val close_in : ('a, 'b) input -> unit
  (** Close the input. It can no longer be read from. *)

val available : ('a, 'b) input -> int
(** returns the number of available single tokens, or raise
  [Not_implemented] if the IO can't deal with it. *)

val pos_in : ('a, 'b) input -> int
(** Returns the number of tokens read, or raise
  [Not_implemented] if the IO can't deal with it. *)

val write : ('a, 'b, 'c) output -> 'a -> unit
(** Write a single token to an output. *)

val nwrite : ('a, 'b, 'c) output -> 'b -> unit
(** Write a token-buffer to an output. *)
										 
val flush : ('a, 'b, 'c) output -> unit
(** Flush an output. *)

val close_out : ('a, 'b, 'c) output -> 'c
(** Close the output and return its accumulator data.
  It can no longer be written. *)

val pos_out : ('a, 'b, 'c) output -> int
(** Return the number of tokens written, or raise
  [Not_implemented] if the IO can't deal with it. *)

val printf : ('a, string, 'b) output -> ('c, unit, string, unit) format4 -> 'c
(** The printf function works for any output where token-buffer is string. *)

(** {6 Creation of IO Inputs/Outputs} *)

val input_string : string -> stdin
(** Create an input that will read from a string. *)

val output_string : unit -> string stdout
(** Create an output that will write into a string in an efficient way.
  When closed, the output returns all the data written into it. *)

val input_channel : in_channel -> stdin
(** Create an input that will read from a channel. *)

val output_channel : out_channel -> unit stdout
(** Create an output that will write into a channel. *) 

val input_enum : 'a Enum.t -> ('a, 'a Enum.t) input
(** Create an input that will read from an [enum]. *)

val output_enum : unit -> ('a, 'a Enum.t, 'a Enum.t) output
(** Create an output that will write into an [enum]. The 
  final enum is returned when the output is closed. *)

val create_in :
  read:(unit -> 'a) ->
  nread:(int -> 'b) ->
  pos:(unit -> int) ->
  available:(unit -> int) -> close:(unit -> unit) -> ('a, 'b) input
(** Fully create an input by giving all the needed functions. *)

val create_out :
  write:('a -> unit) ->
  nwrite:('b -> unit) -> 
  pos:(unit -> int) -> 
  flush:(unit -> unit) -> close:(unit -> 'c) -> ('a, 'b, 'c) output
(** Fully create an output by giving all the needed functions. *)

val pipe : unit -> ('a, 'a list) input * ('a, 'a list,'a list) output
(** Create a pipe between an input and an ouput. Data written from
  the output can be read from the input. [pos_in], [pos_out] and
  [available] are implemented. *)

(** {6 Binary files API}

	Here is some API useful for working with binary files, in particular
	binary files generated by C applications.
*)

exception Overflow of string
(** Exception raised when a read or write operation cannot be completed. *)

val read_byte : (char,'a) input -> int
(** Read an unsigned 8-bit byte. *)

val read_ui16 : (char,'a) input -> int
(** Read an unsigned 16-bit word. *)

val read_i16 : (char,'a) input -> int
(** Read a signed 16-bit word. *)

val read_i32 : (char,'a) input -> int
(** Read a signed 32-bit integer. Raise [Overflow] if the
  read integer cannot be represented as a Caml 31-bit integer. *)

val read_string : (char,'a) input -> string
(** Read a null-terminated string. *)

val read_line : (char,'a) input -> string
(** Read a LF or CRLF terminated string. *)

val write_byte : (char,'a,'b) output -> int -> unit
(** Write an unsigned 8-bit byte. *)

val write_ui16 : (char,'a,'b) output -> int -> unit
(** Write an unsigned 16-bit word. *)

val write_i16 : (char,'a,'b) output -> int -> unit
(** Write a signed 16-bit word. *)

val write_i32 : (char,'a,'b) output -> int -> unit
(** Write a signed 32-bit integer. *) 

val write_string : 'a stdout -> string -> unit
(** Write a string and append an null character. *)

val write_line : 'a stdout -> string -> unit
(** Write a line and append a LF (it might be converted
	to CRLF on some systems depending on the underlying IO). *)

val input_bits : (char,'a) input -> (bool,int) input
(** Enable read from an input on a bit-basis.
	[read ch] will return a bit.
	[nread ch n] will return an n-bit integer.
*)

val output_bits : (char,'a,'b) output -> (bool,(int * int),'b) output
(** Enable writing to an output on a bit-basis.
	[write ch false] will write the bit 0.
	[write ch true] will write the bit 1.
	[nwrite ch (n,v)] will write the unsigned integer [v] using exactly [n] bits.
	Don't forget to call [flush] if you want to write to the original channel
	after you're done with bits-writing.
*)
	
(**/**)

class ['a,'b] o_input : ('a,'b) input ->
  object

	method read : 'a
	method nread : int -> 'b
	method pos : int
	method available : int
	method close : unit

  end

class ['a,'b,'c] o_output : ('a,'b,'c) output ->
  object

	method write : 'a -> unit
	method nwrite : 'b -> unit
	method pos : int
	method flush : unit
	method close : 'c

  end

val from_in : ('a,'b) #o_input -> ('a,'b) input
val from_out : ('a,'b,'c) #o_output -> ('a,'b,'c) output
