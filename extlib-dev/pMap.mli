(*
 * PMap - Polymorphic maps
 * Copyright (C) 1996-2003 Xavier Leroy, Nicolas Cannasse, Markus Mottl
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

type ('a, 'b) t

val empty : ('a, 'b) t
val is_empty : ('a, 'b) t -> bool
val create : ('a -> 'a -> int) -> ('a, 'b) t

val add : 'a -> 'b -> ('a, 'b) t -> ('a, 'b) t
val find : 'a -> ('a, 'b) t -> 'b
val remove : 'a -> ('a, 'b) t -> ('a, 'b) t
val mem : 'a -> ('a, 'b) t -> bool
val exists : 'a -> ('a, 'b) t -> bool

val iter : ('a -> 'b -> unit) -> ('a, 'b) t -> unit
val map : ('b -> 'c) -> ('a, 'b) t -> ('a, 'c) t
val mapi : ('a -> 'b -> 'c) -> ('a, 'b) t -> ('a, 'c) t

val fold : ('b -> 'c -> 'c) -> ('a , 'b) t -> 'c -> 'c
val foldi : ('a -> 'b -> 'c -> 'c) -> ('a , 'b) t -> 'c -> 'c

val enum : ('a, 'b) t -> ('a * 'b) Enum.t
val of_enum : ?cmp:('a -> 'a -> int) -> ('a * 'b) Enum.t -> ('a, 'b) t
