(* Generic database interface for mod_caml programs.
 * Copyright (C) 2003-2004 Merjis Ltd.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this library; if not, write to the Free
 * Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 *
 * $Id: dbi.ml,v 1.1 2004-04-25 09:03:46 ncannasse Exp $
 *)


open Printf

let invalid_arg s = invalid_arg ("Dbi." ^ s)


(*----------------------------------------------------------------------
  Decimal Module
  ----------------------------------------------------------------------*)

module Decimal =
struct
  (* FIXME: This is a STUPID implementation; must be rewritten to use
     big_nums when they will be back in the std distribution. *)

  type t = {
    num : float;
    scale : int;
  }

  let to_string n =
    let s = sprintf "%.15f" n.num in
    let i = String.index s '.' in
    String.sub s 0 (i + 1 + n.scale)

  let to_float n = n.num

  let of_string ?scale s =
    { num = Scanf.sscanf s "%f" (fun f -> f);
      scale = match scale with
      | Some s -> if s < 0 then invalid_arg "Decimal.of_int" else s
      | None -> (try String.length s - (String.index s '.') - 1
                 with Not_found -> 0)
    }

  let of_int ?(scale=0) n =
    if scale < 0 then invalid_arg "Decimal.of_int" else
      { num = float n *. 10.**(float(- scale));
        scale = scale
      }


  let add n m =
    { num = n.num +. m.num; scale = max n.scale m.scale }

  let sub n m =
    { num = n.num -. m.num; scale = max n.scale m.scale }

  let mul n m =
    { num = n.num *. m.num; scale = n.scale + m.scale }

  let div n m =
    { num = n.num /. m.num; scale = n.scale - m.scale }

  let compare n m =
    compare n.num m.num
end


(*----------------------------------------------------------------------
  Dbi module
  ----------------------------------------------------------------------*)

type date = { year : int; month : int; day : int; }

type time = { hour : int; min : int; sec : int; microsec : int;
	      timezone : int option }

type datetime = date * time

type sql_t = [ `Null			(* NULL value *)
	     | `Int of int		(* integer, smallint *)
             | `Float of float		(* double precision, real *)
	     | `String of string	(* char, varchar, text *)
	     | `Bool of bool		(* boolean *)
	     (* | `Bigint of Bigint.big_int (* bigint *) *)
	     | `Decimal of Decimal.t	(* numeric, decimal *)
	     | `Date of date		(* date *)
	     | `Time of time		(* time (with/without TZ) *)
	     | `Timestamp of datetime	(* timestamp (with/without TZ) *)
	     | `Interval of datetime	(* interval (no TZ) *)
	     (* | `Blob of blob           (* blob *) *)
	     | `Binary of string        (* Postgres's BYTEA and equivalent *)
	     | `Unknown of string	(* cannot be represented by any above*)
	     ]

let sql_t_to_string = function
  | `Null -> "NULL"
  | `Int i -> string_of_int i
  | `Float f -> string_of_float f
  | `String s -> s
  | `Bool b -> string_of_bool b
(*  | `Bigint i -> string_of_big_int i *)
  | `Decimal d -> Decimal.to_string d
  | `Date date -> sprintf "%04i-%02i-%02i" date.year date.month date.day
  | `Time time -> sprintf "%04i:%02i:%02i" time.hour time.min time.sec
  | `Timestamp (d,t) ->
      sprintf "%04i-%02i-%02i %02i:%02i:%02i"
      d.year d.month d.day t.hour t.min t.sec
  | `Interval (d,t) ->
      sprintf "%04i-%02i-%02i %02i:%02i:%02i"
      d.year d.month d.day t.hour t.min t.sec
  | `Blob _ -> "<blob>"
  | `Binary s -> "<binary>"
  | `Unknown s -> s


let sql_t_type = function
  | `Null -> "`Null"
  | `Int _ -> "`Int"
  | `Float _ -> "`Float"
  | `String _ -> "`String"
  | `Bool _ -> "`Bool"
  | `Bigint _ -> "`Bigint"
  | `Decimal _ -> "`Decimal"
  | `Date _ -> "`Date"
  | `Time _ -> "`Time"
  | `Timestamp _ -> "`Timestamp"
  | `Interval _ -> "`Interval"
  | `Blob _ -> "`Blob"
  | `Binary s -> "`Binary"
  | `Unknown _ -> "`Unknown"

let sdebug s =
  let display = function
    | `Null -> "`Null"
    | x -> sql_t_type x ^ " " ^ sql_t_to_string x  in
  "[" ^ String.concat "; " (List.map display s) ^ "]"

let intoption = function
  | None -> `Null
  | Some i -> `Int i

let stringoption = function
  | None -> `Null
  | Some s -> `String s

(* Replaces "\\" with "\\\\" and "'" with "''" and anything < 0x20
   with its octal representation "\\ooo".  Accented letters (above
   0x7e) need not to be escaped.
*)
let is_printable c = (0x20 <= int_of_char c)

let string_escaped s =
  let n = ref 2 in
  for i = 0 to String.length s - 1 do
    n := !n + (match String.unsafe_get s i with
		 | '\'' | '\\' | '\n' | '\t' -> 2
		 | c -> if is_printable c then 1 else 4)
  done;
  if !n = String.length s then s else begin
    let s' = String.create !n in
    String.unsafe_set s' 0 '\'';
    n := 1;
    for i = 0 to String.length s - 1 do
      begin
        match String.unsafe_get s i with
          | '\'' ->
              String.unsafe_set s' !n '\''; incr n;
	      String.unsafe_set s' !n '\''
          | '\\' ->
              String.unsafe_set s' !n '\\'; incr n;
	      String.unsafe_set s' !n '\\'
          | '\n' ->
              String.unsafe_set s' !n '\\'; incr n;
	      String.unsafe_set s' !n 'n'
          | '\t' ->
              String.unsafe_set s' !n '\\'; incr n;
	      String.unsafe_set s' !n 't'
          | c ->
              if is_printable c then
		String.unsafe_set s' !n c
              else begin
		let a = Char.code c in
		String.unsafe_set s' !n '\\';                       incr n;
		String.unsafe_set s' !n (Char.chr (48 + a / 64));   incr n;
		String.unsafe_set s' !n (Char.chr (48 + (a / 8) mod 8));
		                                                    incr n;
		String.unsafe_set s' !n (Char.chr (48 + a mod 8))
              end
      end;
      incr n
    done;
    String.unsafe_set s' !n '\'';
    s'
  end

let placeholders n =
  if n <= 0 then invalid_arg "placeholders";
  let s = String.create (2*n+1) in
  s.[0] <- '(';
  for i = 0 to n - 1 do
    let i2 = 2 * i in
    s.[1 + i2] <- '?';
    s.[2 + i2] <- ',';
  done;
  s.[2*n] <- ')';
  s

type precommit_handle = int
type postrollback_handle = int

(* Exceptions thrown by subclasses on SQL errors. *)
exception SQL_error of string

(* This is used for generating unique integers. *)
let unique =
  let next = ref 0 in
  fun () ->
    incr next;
    !next


class virtual statement connection =
object (self)

  method virtual execute : sql_t list -> unit

  method virtual fetch1 : unit -> sql_t list

  method virtual names : string list

  method fetchall () =
    let rows = ref [] in
    try
      while true do rows := self#fetch1() :: !rows done;
      assert false (* keep type system happy, never reached *)
    with
      Not_found -> List.rev !rows

  method fetch1int () =
    match self#fetch1() with
    | [`Int i] -> i
    | _ -> invalid_arg "fetch1int"

  method fetch1string () =
    match self#fetch1() with
    | [`String i] -> i
    | _ -> invalid_arg "fetch1string"

  method iter (f : sql_t list -> unit) =
    try
      while true do f (self#fetch1()) done
    with
      Not_found -> ()

  method map : 'a . (sql_t list -> 'a) -> 'a list =
    fun f ->
      let list = ref [] in
      try
        while true do list := f (self#fetch1()) :: !list done;
        assert false
      with
	Not_found -> List.rev !list

  method fold_left : 'a . ('a -> sql_t list -> 'a) -> 'a -> 'a =
    fun f b ->
      let v = ref b in
      try
        while true do v := f !v (self#fetch1()) done;
        assert false
      with
	Not_found -> !v

  (* Watch out. [fold_right] is not tail recursive. *)
  method fold_right : 'a . (sql_t list -> 'a -> 'a) -> 'a -> 'a =
    fun f b0 ->
      let rec loop () =
	try
	  let row = self#fetch1 () in
	  f row (loop ())
	with
	    Not_found -> b0
      in
      loop ()


  method fetch1hash () =
    (* Remark: drivers should cache the names -- or use another way to
       construct the assoc list. *)
    List.map2 (fun a b -> (a,b)) (self#names) (self#fetch1())

  method virtual serial : string -> int

  method finish () = ()

  method connection = (connection : connection)
end


and virtual connection ?host ?port ?user ?password database =

  (* Unique integer identifying this connection. *)
  let id = unique () in

  (* List of precommit handlers. *)
  let precommits = ref [] in

  (* List of postrollback handlers. *)
  let postrollbacks = ref [] in

object (self)

  method id = id

  (* Debugging flag. *)
  val mutable debug = false

  method set_debug b =
    debug <- b;
    eprintf "Dbi: dbh %d: debugging %s.\n" id
      (if b then "enabled" else "disabled");
    flush stderr
  method debug = debug

  (* Subclasses should check the [closed] flag before starting any
     operations.  *)
  val mutable closed = false
  method closed = closed

  (* These are default implementations which just return the parameters
   * passed to the class. In some subclasses it makes sense to override
   * these, particularly with databases like PostgreSQL where the [database]
   * parameter is really a full [conninfo] string.
   *)
  method host = (host : string option)
  method port = (port : string option)
  method user = (user : string option)
  method password = (password : string option)
  method database = (database : string)

  method virtual database_type : string

  method virtual prepare : string -> statement

  (* This contains the cached statements associated with this connection. *)
  val cache = Hashtbl.create 16

  method prepare_cached query =
    try
      Hashtbl.find cache query
    with
	Not_found ->
	  let sth = self#prepare query in
	  Hashtbl.add cache query sth;
	  sth

  method ex query args =
    let sth = self#prepare_cached query in
    sth#execute args;
    sth

  (* Subclasses should implement precommit handlers by calling the
   * superclass method first.
   *)
  method commit () =
    List.iter (fun (_, f) -> f()) !precommits

  (* Subclasses should implement postrollback handlers by calling the
   * superclass method last.
   *)
  method rollback () =
    List.iter (fun (_, f) -> f()) !postrollbacks

  method register_precommit f =
    let i = unique() in
    precommits := (i, f) :: !precommits;
    i

  method unregister_precommit i =
    precommits := List.remove_assoc i !precommits

  method register_postrollback f =
    let i = unique() in
    postrollbacks := (i, f) :: !postrollbacks;
    i

  method unregister_postrollback i =
    postrollbacks := List.remove_assoc i !postrollbacks

  (* The default implementation of [close] finishes any cached handles.
   * Subclasses will want to override this and call this superclass.
   *)
  method close () =
    Hashtbl.iter (fun _ sth -> sth#finish()) cache;
    Hashtbl.clear cache;
    closed <- true;
    if debug then ( eprintf "Dbi: dbh %d: closed.\n" id; flush stderr )

  (* The default implementation of 'ping'. Subclasses may need to
   * override this with a more suitable implementation.
   *)
  method ping () =
    try
      let sth = self#prepare_cached "SELECT 1" in
      sth#execute [];
      sth#finish();
      if debug then (
        eprintf "Dbi: dbh %d: ping succeeded.\n" id; flush stderr );
      true
    with
      SQL_error str ->
        if debug then (
          eprintf "Dbi: dbh %d: ping failed with error: %s.\n" id str;
          flush stderr
        );
	false
end


module Factory = struct
  (* List of registered database types. *)
  let types = Hashtbl.create 8

  let database_types () =
    Hashtbl.fold (fun x _ xs -> x :: xs) types []

  let connect database_type ?host ?port ?user ?password database_name =
    try
      let connect = Hashtbl.find types database_type in
      connect ?host ?port ?user ?password database_name
    with
      Not_found ->
	let keys = String.concat ", " (database_types()) in
	invalid_arg ("Dbi.Factory.connect: database type " ^
		     database_type ^ " is not known.  Known types: " ^
		     keys)


  let register (database_type : string) connect =
    Hashtbl.replace types database_type connect
end
