(* 
 * IO - Abstract input/ouput
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

type ('a, 'b) input
type ('a, 'b, 'c) output

exception No_more_input
exception Input_closed
exception Output_closed

val default_available : unit -> 'a option
val default_close : unit -> unit

val create_in :
  read:(unit -> 'a) ->
  nread:(int -> 'b) ->
  available:(unit -> int option) -> close:(unit -> unit) -> ('a, 'b) input

val create_out :
  write:('a -> unit) ->
  nwrite:('b -> unit) -> 
  flush:(unit -> unit) -> close:(unit -> 'c) -> ('a, 'b, 'c) output


val read : ('a, 'b) input -> 'a
val nread : ('a, 'b) input -> int -> 'b
val available : ('a, 'b) input -> int option
val close_in : ('a, 'b) input -> unit

val write : ('a, 'b, 'c) output -> 'a -> unit
val nwrite : ('a, 'b, 'c) output -> 'b -> unit
val printf : ('a, string, 'b) output -> ('c, unit, string, unit) format4 -> 'c
val flush : ('a, 'b, 'c) output -> unit
val close_out : ('a, 'b, 'c) output -> 'c

val input_string : string -> (char, string) input
val output_string : unit -> (char, string, string) output

val input_channel : in_channel -> (char, string) input
val output_channel : out_channel -> (char, string, unit) output

val input_enum : 'a Enum.t -> ('a, 'a Enum.t) input
val output_enum : unit -> ('a, 'a Enum.t, 'a Enum.t) output