(*
 * Base64 - Base64 codec
 * Copyright (C) 2003 Nicolas Cannasse
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
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

(** Base64 codec.

 8-bit characters are encoded into 6-bit ones using ASCII characters A-Z,
 a-z, 0-9, and '+' , '/' (in that order). *)

(** This exception is raised when reading an invalid character
	from a base64 input. *)
exception Invalid_char

(** Encode a string into Base64. *)
val str_encode : string -> string

(** Decode a string encoded into Base64, raise [Invalid_char] if a
	character in the input string is not a valid one. *)
val str_decode : string -> string

(** Generic base64 encoding over an output. *)
val encode : (char, 'a, 'b) IO.output -> (char, string, 'b) IO.output

(** Generic base64 decoding over an input. *)
val decode : (char, 'a) IO.input -> (char, string) IO.input
