(* 
 * IOO - OO Wrappers for IO
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

(** OO Wrappers for IO.

	Theses OO Wrappers have been written to provide easy support of ExtLib
	IO by external librairies. If you want your library to support ExtLib
	IO without actually requiring ExtLib to compile, you have two choices :
	
	You can implement classes having the same signatures as [o_input] and 
	[o_output], then the ExtLib user will be able to create an IO using
	[from_in] and [from_out] functions. Theses classes are providing the
	same facilities than IO, and are then following the same specification.

	You can also implement the classes [in_channel], [out_channel],
	[poly_in_channel] and/or [poly_out_channel] which are the common IO
	specifications established for ExtLib, OCamlNet and Camomile. It
	provides a more generic interface, but with less features.
*)

class ['a,'b] o_input : ('a,'b) IO.input ->
  object
	method read : 'a
	method nread : int -> 'b
	method pos : int
	method available : int
	method close : unit
  end

class ['a,'b,'c] o_output : ('a,'b,'c) IO.output ->
  object
	method write : 'a -> unit
	method nwrite : 'b -> unit
	method pos : int
	method flush : unit
	method close : 'c
  end

val from_in : ('a,'b) #o_input -> ('a,'b) IO.input
val from_out : ('a,'b,'c) #o_output -> ('a,'b,'c) IO.output

(** {6 Generic IO Object Wrappers}*)

class in_channel : ('a,string) IO.input ->
  object
	method input : string -> int -> int -> int
	method close_in : unit -> unit
  end

class out_channel : ('a,string,'b) IO.output ->
  object
	method output : string -> int -> int -> int
	method flush : unit -> unit
	method close_out : unit -> unit
  end

class ['a] poly_in_channel : ('a,'b) IO.input ->
  object
	method get : unit -> 'a
	method close_in : unit -> unit
  end

class ['a] poly_out_channel : ('a,'b,'c) IO.output ->
  object
	method put : 'a -> unit
	method flush : unit -> unit
	method close_out : unit -> unit
  end

val from_in_channel : #in_channel -> (char,string) IO.input
val from_out_channel : #out_channel -> (char,string,unit) IO.output
val from_poly_in_channel : 'a #poly_in_channel -> ('a,'a list) IO.input
val from_str_in_channel : char #poly_in_channel -> (char,string) IO.input
val from_poly_out_channel : 'a #poly_out_channel -> ('a,'a list,unit) IO.output
val from_str_out_channel : char #poly_out_channel -> (char,string,unit) IO.output

