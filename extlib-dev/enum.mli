
(* Enum, a lazy implementation of abstracts enumerators
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
 *
 *)

type 'a t

exception No_more_elements

val make : next:(unit -> 'a) -> count:(unit -> int) -> 'a t

val count : 'a t -> int

val has_more : 'a t -> bool

val next : 'a t -> 'a

val iter : ('a -> unit) -> 'a t -> unit

val iteri : (int -> 'a -> unit) -> 'a t -> unit

val fold : ('a -> 'b -> 'b) -> 'b -> 'a t -> 'b

val find : ('a -> bool) -> 'a t -> 'a (* raise Not_found *)

val force : 'a t -> unit

(* Lazy operations, cost O(1) *)

val map : ('a -> 'b) -> 'a t -> 'b t

val mapi : (int -> 'a -> 'b) -> 'a t -> 'b t

val filter : ('a -> bool) -> 'a t -> 'a t

val append : 'a t -> 'a t -> 'a t

val concat : 'a t t -> 'a t

