(*
 * psq- an ocaml implementation of priority search queues.
 * Copyright (C) 2003 Brian Hurt
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

(** Priority Search Queue implementation.

    This module implements priority search queues.  Priority search queues
    combine the efficiencies of search trees (O(log n) insert, remove, and
    search) as well as the efficiencies of heaps (O(1) to find the highest
    priority element, O(log n) to change the priority of an element or to
    remove the highest priority element).

    The implementation here is the same one described by Ralf Hinze
    (ralf @ cs.uu.nl) in the paper "A Simple Implementation Technique for
    Priority Search Queues".  Reading the paper before reading the code is
    highly recommended.

    All operations are purely applicative (no side-effects).  This
    implementation uses Red-Black trees as it's balancing algorithm.
*)

type ('a, 'b) t (** The type of priority search queues *)

exception Empty
(** Thrown when a head, find, precise adjust, or precise deletion is
    attempted on an empty queue. *)

exception Exists
(** Thrown when a precise insertion is attempted with a key that
    already exists in the queue. *)

val create : ('a -> 'a -> int) -> ('b -> 'b -> int) -> ('a, 'b) t

val head : ('a, 'b) t -> 'b
(** Returns the head (highest priority) element of the queue.
    This is an O(1) operation.
    @raise Empty if the queue is empty. *)

val head_key : ('a, 'b) t -> 'a

val is_empty : ('a, 'b) t -> bool
(** Returns true if the queue is empty.  This is an O(1) operation. *)

val to_ord_list : ('a, 'b) t -> ('a * 'b) list
(** Returns all elements of the queue in sorted order by increasing
    key.  This is an O(n) operation. *)

val to_pri_list : ('a, 'b) t -> ('a * 'b) list
(** Returns all elements of the queue in sorted order by decreasing
    priority.  This is an O(n log n) operation. *)

(* Precise operations- these operations throw exceptions on
 * unexpected cases.
 *)

val find : 'a -> ('a, 'b) t -> 'b
(** Precise search.
    [find x q] returns the current binding of [x] in [q].
    @raise Not_found if no such binding exists. *)

val adjust : ('b -> 'b) -> 'a -> ('a, 'b) t -> ('a, 'b) t
(** Precise priority adjustment.
    [adjust f k q] changes the priority of the element bound to
    [k] in [q] by applying [f] to it.
    @raise Not_found if no such binding exists
    @raise Empty if [q] is empty (contains no bindings). *)

val add : 'a -> 'b -> ('a, 'b) t -> ('a, 'b) t
(** Precise insertion.
    [add k e q] returns a queue containing the same bindings as [q]
    plus a binding of [k] to [e].
    @raise Exists if a binding for [k] already exists *)

val remove : 'a -> ('a, 'b) t -> ('a, 'b) t
(** Precise deletion.
    [remove k q] returns a queue containing the same bindings as [q]
    except for the binding from [k], which is unbound in the returned
    queue.
    @raise Not_found if the key does not have a binding in the given 
    queue
    @raise Empty if the given queue is empty. *)

val remove_head : ('a, 'b) t -> ('a, 'b) t
(** Precise head removal.
    [remove_head q] returns a queue with the same mappings as [q]
    except that the mapping with the highest priority element is
    unbound (removed).
    @raise Empty if the given queue is empty. *)

(* Imprecise operations- these "nice" operations don't raise
 * exceptions, they just do something more or less intelligent
 * in unexpected situations.
 *)

val contains : 'a -> ('a, 'b) t -> bool
(** [contains x q] evaluates to true if a binding for [x] exists in
    [q], false otherwise. *)

val query : 'a -> ('a, 'b) t -> 'b option
(** Imprecise search.
    [query k q] returns the current binding of [k] in [q] as Some x, or
    None if no such binding exists.  This is different from [find]
    in its behavior when the key does not exist in the queue. *)

val update : ('b -> 'b) -> 'a -> ('a, 'b) t -> ('a, 'b) t
(** Imprecise priority adjustment.
    [update f k q] changes the priority of the element bound to
    [k] in [q] by applying [f] to it.  If [k] is not bound in
    [q], nothing happens. *)

val insert : 'a -> 'b -> ('a, 'b) t -> ('a, 'b) t
(** Imprecise insertion.
    [insert k e q] returns a queue containing the same bindings as [q]
    plus a binding of [k] to [e].  If [k] is already bound in [q],
    its previous binding is replaced by the new binding. *)

val delete : 'a ->  ('a, 'b) t ->  ('a, 'b) t
(** Imprecise deletion.
    [remove k q] returns a queue containing the same bindings as [q]
    except for the binding from [k], which is unbound in the returned
    queue.  If [k] is not bound in [q], the returned queue is the
    same as [q]. *)

val delete_head : ('a, 'b) t -> ('a, 'b) t
(** Imprecise head removal.
    [delete_head q] returns a queue with the same mappings as [q]
    except that the mapping with the highest priority element is
    unbound (removed).  If [q] is empty, the empty queue is returned.
    *)

val queue_to_string : ('a -> string) -> ('b -> string) -> ('a, 'b) t -> string
(** Creates a string representation of the queue (for I/O).
    This function is horribly inefficient.  Only use it for debugging.
 *)

