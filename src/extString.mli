(*
 * ExtString - Additional functions for string manipulations.
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

(** Additional functions for string manipulations. *)

exception Invalid_string

module String :
  sig

  val empty: string
  (** The empty string. *)

  (** {6 New Functions} *)

  val init : int -> (int -> char) -> string
  (** [init l f] returns the string of length [l] with the chars
      f 0 , f 1 , f 2 ... f (l-1). *)

  val find : string -> string -> int
  (** [find s x] returns the starting index of the string [x]
      within the string [s] or raises [Invalid_string] if [x]
      is not a substring of [s]. *)

  val find_from : string -> int -> string -> int
  (** [find s i x] returns the starting index of the string [x]
      within the string [s] (starting search from position [i]) or
      raises [Invalid_string] if no such substring exists.
      [find s x] is equivalent to [find_from s 0 x]. *)

  val split : string -> string -> string * string
  (** [split s sep] splits the string [s] between the first
      occurrence of [sep].
      raises [Invalid_string] if the separator is not found. *)

  val nsplit : string -> string -> string list
  (** [nsplit s sep] splits the string [s] into a list of strings
      which are separated by [sep].
      [nsplit "" _] returns the empty list.
      @raise Invalid_string if [sep] is empty string. *)

  val join : string -> string list -> string
  (** Same as [concat] *)

  val slice : ?first:int -> ?last:int -> string -> string
  (** [slice ?first ?last s] returns a "slice" of the string
      which corresponds to the characters [s.[first]],
      [s.[first+1]], ..., [s[last-1]]. Note that the character at
      index [last] is {b not} included! If [first] is omitted it
      defaults to the start of the string, i.e. index 0, and if
      [last] is omitted is defaults to point just past the end of
      [s], i.e. [length s].  Thus, [slice s] is equivalent to
      [copy s].

      Negative indexes are interpreted as counting from the end of
      the string. For example, [slice ~last:-2 s] will return the
      string [s], but without the last two characters.

      This function {b never} raises any exceptions. If the
      indexes are out of bounds they are automatically clipped.
  *)

  val lchop : string -> string
  (** Returns the same string but without the first character.
      does nothing if the string is empty. *)

  val rchop : string -> string
  (** Returns the same string but without the last character.
     does nothing if the string is empty. *)

  val of_int : int -> string
  (** Returns the string representation of an int. *)

  val of_float : float -> string
  (** Returns the string representation of an float. *)

  val of_char : char -> string
  (** Returns a string containing one given character. *)

  val to_int : string -> int
  (** Returns the integer represented by the given string or
      raises [Invalid_string] if the string does not represent an integer.*)

  val to_float : string -> float
  (** Returns the float represented by the given string or
      raises Invalid_string if the string does not represent a float. *)

  val ends_with : string -> suffix:string -> bool
  (** [ends_with s ~suffix] returns true if the string [s] is ending with [suffix]. *)

  val starts_with : string -> prefix:string -> bool
  (** [starts_with s ~prefix] return true if [s] is starting with [prefix]. *)

  val enum : string -> char Enum.t
  (** Returns an enumeration of the characters of a string.*)

  val of_enum : char Enum.t -> string
  (** Creates a string from a character enumeration. *)

  val map : (char -> char) -> string -> string
  (** [map f s] returns a string where all characters [c] in [s] have been
      replaced by [f c]. **)

  val mapi : (int -> char -> char) -> string -> string
  (** [map f s] returns a string where all characters [c] in [s] have been replaced
      by [f i s.\[i\]]. **)

  val iteri : (int -> char -> unit) -> string -> unit
  (** Call [f i s.\[i\]] for every position [i] in string *)

  val fold_left : ('a -> char -> 'a) -> 'a -> string -> 'a
  (** [fold_left f a s] is
      [f (... (f (f a s.[0]) s.[1]) ...) s.[n-1]] *)

  val fold_right : (char -> 'a -> 'a) -> string -> 'a -> 'a
  (** [fold_right f s b] is
      [f s.[0] (f s.[1] (... (f s.[n-1] b) ...))] *)

  val explode : string -> char list
  (** [explode s] returns the list of characters in the string [s]. *)

  val implode : char list -> string
  (** [implode cs] returns a string resulting from concatenating
      the characters in the list [cs]. *)

  val strip : ?chars:string -> string -> string
  (** Returns the string without the chars if they are at the beginning or
      at the end of the string. By default chars are " \t\r\n". *)

  val exists : string -> sub:string -> bool
  (** [exists str ~sub] returns true if [sub] is a substring of [str] or
      false otherwise. *)

  val replace_chars : (char -> string) -> string -> string
  (** [replace_chars f s] returns a string where all chars [c] of [s] have been
      replaced by the string returned by [f c]. *)

  val replace : str:string -> sub:string -> by:string -> bool * string
  (** [replace ~str ~sub ~by] returns a tuple constisting of a boolean
      and a string where the first occurrence of the string [sub]
      within [str] has been replaced by the string [by]. The boolean
      is true if a subtitution has taken place. *)

  val trim : string -> string
  (** Return a copy of the argument, without leading and trailing
      whitespace.  The characters regarded as whitespace are:
      [' '], ['\012'], ['\n'], ['\r'], and ['\t'].
      (Note that it is different from {!strip} defaults). *)


  (** {6 Compatibility Functions} *)

  val uppercase_ascii : string -> string
  val lowercase_ascii : string -> string
  val capitalize_ascii : string -> string
  val uncapitalize_ascii : string -> string

  val split_on_char : char -> string -> string list


  (** {6 Older Functions} *)

  (** Please refer to the OCaml Manual for documentation of these
      functions. *)

  val length : string -> int
  val get : string -> int -> char
  val set : Bytes.t -> int -> char -> unit [@@ocaml.deprecated "Use Bytes.set instead."]
  val create : int -> Bytes.t [@@ocaml.deprecated "Use Bytes.create instead."]
  val make : int -> char -> string
  val copy : string -> string [@@ocaml.deprecated]
  val sub : string -> int -> int -> string
  val fill : Bytes.t -> int -> int -> char -> unit [@@ocaml.deprecated "Use Bytes.fill instead."]
  val blit : string -> int -> Bytes.t -> int -> int -> unit
  val concat : string -> string list -> string
  val iter : (char -> unit) -> string -> unit
  val escaped : string -> string
  val index : string -> char -> int
  val index_opt : string -> char -> int option
  val rindex : string -> char -> int
  val rindex_opt : string -> char -> int option
  val index_from : string -> int -> char -> int
  val index_from_opt : string -> int -> char -> int option
  val rindex_from : string -> int -> char -> int
  val rindex_from_opt : string -> int -> char -> int option
  val contains : string -> char -> bool
  val contains_from : string -> int -> char -> bool
  val rcontains_from : string -> int -> char -> bool

  val uppercase : string -> string [@@ocaml.deprecated "Use String.uppercase_ascii instead."]

  val lowercase : string -> string [@@ocaml.deprecated "Use String.lowercase_ascii instead."]

  val capitalize : string -> string [@@ocaml.deprecated "Use String.capitalize_ascii instead."]

  val uncapitalize : string -> string [@@ocaml.deprecated "Use String.uncapitalize_ascii instead."]

  type t = string
  val compare : t -> t -> int
  val equal : t -> t -> bool

#if OCAML >= 407
  (** [*_seq] functions were introduced in OCaml 4.07.0, and are _not_ implemented in extlib for older OCaml versions *)
  val to_seq : t -> char Seq.t
  val to_seqi : t -> (int * char) Seq.t
  val of_seq : char Seq.t -> t
#endif

  (**/**)

  external unsafe_get : string -> int -> char = "%string_unsafe_get"
  val unsafe_set : Bytes.t -> int -> char -> unit [@@ocaml.deprecated]
  val unsafe_blit : string -> int -> Bytes.t -> int -> int -> unit
  val unsafe_fill : Bytes.t -> int -> int -> char -> unit [@@ocaml.deprecated]

  end
