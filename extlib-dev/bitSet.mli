(*
 * Bitset - Efficient bit sets
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

(** Efficient bit sets.

 A bitset is a array of boolean values that can be accessed with indexes
 like an array but provide a better memory usage (divided by 32) for a
 very small speed tradeoff. *)

type t

exception Negative_index of string
(** When a negative bit value is used for one of the BitSet functions,
 this exception is raised with the name of the function. *)

val empty : unit ->  t
(** Create an empty bitset of size 0, the bitset will automaticaly expands
 when needed. *)

val create : int -> t
(** Create an empty bitset with an initial size (in number of bits). *)

val clone : t -> t
(** Clone a bitset : further modifications of first one will not affect the
 clone. *)

val set : t -> int -> unit
(** [set s n] set the nth-bit in the bitset [s] to true. *)
 
val unset : t -> int -> unit
(** [unset s n] set the nth-bit in the bitset [s] to false. *) 

val put : t -> bool -> int -> unit
(** [put s v n] set the nth-bit in the bitset [s] to [v]. *)

val toggle : t -> int -> unit
(** [toggle s n] change the nth-bit value in the bitset [s]. *)

val is_set : t -> int -> bool
(** [is_set s n] return true if nth-bit it the bitset [s] is set,
 or false otherwise. *)

val compare : t -> t -> int
(** [compare s1 s2] compare two bitsets. Highest bit indexes are
 compared first. *)

val equals : t -> t -> bool
(** [equals s1 s2] return true if all bits value in s1 are same as s2. *)

val count : t -> int
(** [count s] returns the number of bits set in the bitset [s]. *)

val enum : t -> int Enum.t
(** [enum s] return an enumeration of bit indexed which are set
 in the bitset [s]. *)
