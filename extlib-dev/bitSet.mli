(*
 * Bitset - Efficient bit sets
 * Copyright (C) 2003 Nicolas Cannasse (ncannasse@motion-twin.com)
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

exception Negative_index of string

type t

val empty : unit ->  t
val create : int -> t
val clone : t -> t

val set : t -> int -> unit
val unset : t -> int -> unit
val toggle : t -> int -> unit

val is_set : t -> int -> bool

val compare : t -> t -> int
val equals : t -> t -> bool

val count : t -> int
val enum : t -> int Enum.t
