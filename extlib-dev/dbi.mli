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
 * $Id: dbi.mli,v 1.1 2004-04-25 09:03:46 ncannasse Exp $
 *)

(** Generic database interface.
  *
  * Making a connection to a specific type of database:
  *
 {[  module DB = Dbi_postgres
  *  let dbh = new DB.connection "database_name"  ]}
  *
  * Equivalent to above, except that we make a connection to a named
  * type of database:
  *
 {[  let dbh =
  *    try Dbi.Factory.connect "postgres" "database_name"
  *    with Not_found -> failwith "Postgres driver not available."   ]}
  *
  * From Apache, using persistent connections (see [Apache.DbiPool]):
  *
 {[  let dbh = Apache.DbiPool.get r "postgres" "database_name"    ]}
  *
  * Simple usage, returning one row:
  *
 {[  let sth = dbh#prepare "SELECT name FROM employees WHERE empid = ?" in
  *  sth#execute [`Int 100];
  *  let [`String name] = sth#fetch1 in ...    ]}
  *
  * Simple usage, returning multiple rows:
  *
 {[  let sth = dbh#prepare "SELECT firstname, name FROM employees
  *                         WHERE salary > ?" in
  *  sth#execute [`Int 10000];
  *  sth#iter(function
  *           | [(`Null | `String _) as fname, `String name] ->
  *               do_something_with fname name
  *           | _ -> assert false);                                ]}
  *
  * Advanced usage, reusing prepared statements:
  *
 {[  let sth =
  *    dbh#prepare "INSERT INTO employees(name, salary) VALUES (?, ?)" in
  *  List.iter(fun (name, salary) ->
  *              sth#execute [`String name; `Int salary];
  *              let id = sth#serial "" in
  *              Printf.printf "Employee %s has been assigned ID %d\n" name id
  *           ) employees_list;                                         ]}
  *)


(** {1 Caml mappings of SQL types.} *)

type date = { year : int; month : int; day : int; }

type time = { hour : int; min : int; sec : int; microsec : int;
	      timezone : int option }

type datetime = date * time

module Decimal :
sig
  (** Module to handle arbitrary precision decimal numbers.

    A decimal number is represented internally in base 10 and
    characterized by its precision (i.e., its total number of digits)
    and its scale.  For example, 103.12 has precision 5 (or more) and
    scale 2.  In this implementation, the precision is taken as
    +infinity and the scale adapts dynamically.
  *)

  type t
    (** Abstract type for decimal numbers *)

  val to_string : t -> string
    (** [to_string n] returns a string representation of the decimal
      number [n]. *)
  val to_float : t -> float
    (** [to_float n] returns the closer float to [n]. *)
  val of_string : ?scale:int -> string -> t
    (** [of_string ?scale s] returns the decimal number represented by
      the string [s].  If the option [scale] is not set, the scale
      will be the one of the string representation.  If [scale] is
      given, it will be enforced, possibly truncating the number.

      @raise Invalid_argument if [scale < 0].
    *)
  val of_int : ?scale:int -> int -> t
    (** [of_int ?scale i] returns the decimal number [i * 10**(-scale)].

      @param scale Scaling of [i] (default: 0).
      @raise Invalid_argument if [scale < 0].
    *)

  val add : t -> t -> t
    (** [add n m] returns the sum of [n] and [m]. *)
  val sub : t -> t -> t
    (** [sub n m] returns the difference of [n] by [m]. *)
  val mul : t -> t -> t
    (** [mul n m] returns the product of [n] and [m]. *)
  val div : t -> t -> t
    (** [div n m] returns the division of [n] by [m]. *)

  val compare : t -> t -> int
    (** [compare n m] returns [0] if [x=y], a negative integer if
      [x<y], and a positive integer if [x>y]. *)
end


(* Some types not yet implemented. XXX *)
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

val sql_t_to_string : sql_t -> string
(** [sql_t_to_string t] returns a string representation of [t]
  * following the Ocaml conventions.  The aim is to offer an easy way
  * to print [sql_t] values.
  *)

val sdebug : sql_t list -> string
(** [sdebug ss] can be used to debug the return value from a [#fetch1],
  * [#map] or other query.  It converts the [sql_t list] type into a
  * printable form which can be printed on [stderr] to aid in debugging
  * the actual types returned by the database.
  *)

val intoption : int option -> sql_t
(** [intoption(Some i)] returns [`Int i] and
  [intoption None] returns [`Null]. *)
val stringoption : string option -> sql_t
(** [stringoption(Some s)] returns [`String s] and
  * [stringoption None] returns [`Null]. *)

type precommit_handle
(** See {!Dbi.connection.register_precommit}. *)
type postrollback_handle
(** See {!Dbi.connection.register_postrollback}. *)


(** {1 SQL utility functions.} *)

val string_escaped : string -> string
(** [escape_string s] escapes the string [s] according to SQL rules
  * and surrounds it with single quotes.  This should be hardly needed
  * as the data provided through the sql_t types will automatically be
  * escaped.
  *)

val placeholders : int -> string
(** [placeholders n] returns a string of the form "(?, ?, ..., ?)" containing
  * [n] question marks.
  * @raise Invalid_argument if [n <= 0].
  *)

exception SQL_error of string
(** Exceptions thrown by subclasses on SQL errors. *)

class virtual statement :
  connection ->
object
  method virtual execute : sql_t list -> unit
    (** Execute the statement with the given list of arguments substituted
      * for [?] placeholders in the query string.  This method should
      * be executed before trying to fetch data.
      *
      * This command can throw a variety of SQL-specific exceptions.
      *)

  method virtual fetch1 : unit -> sql_t list
    (** Fetches one row from the result set and returns it.
      * @raise Not_found if no tuple is returned by the database.
      * @raise Failure if [#execute] has not been issued before.  *)

  method fetch1int : unit -> int
    (** This fetches a single integer field.
      * @raise Not_found if no tuples are remaining.
      * @raise Invalid_argument if the tuple does not contain a single integer.
      * @raise Failure if [#execute] has not been issued before.  *)

  method fetch1string : unit -> string
    (** This fetches a single string field.
      * @raise Not_found if no tuples are remaining.
      * @raise Invalid_argument if the tuple does not contain a single string.
      * @raise Failure if [#execute] has not been issued before.  *)

  method fetchall : unit -> sql_t list list
    (** This returns a list of all tuples returned from the query. Note
      * that this may be less efficient than reading them one at a time.
      * @raise Failure if [#execute] has not been issued before.  *)

  method iter : (sql_t list -> unit) -> unit
    (** Iterate over the result tuples.
      * @raise Failure if [#execute] has not been issued before.  *)

  method map : 'a . (sql_t list -> 'a) -> 'a list
    (** Map over the result tuples.
      * @raise Failure if [#execute] has not been issued before.  *)

  method fold_left : 'a . ('a -> sql_t list -> 'a) -> 'a -> 'a
    (** Fold left over the result tuples.
      * @raise Failure if [#execute] has not been issued before.  *)

  method fold_right : 'a . (sql_t list -> 'a -> 'a) -> 'a -> 'a
    (** Fold right over the result tuples.  Not tail-recursive.
      * @raise Failure if [#execute] has not been issued before.  *)

  method virtual names : string list
    (** Returns the names of the columns of the result.
      * @raise Failure if [#execute] has not been issued before.  *)

  method fetch1hash : unit -> (string * sql_t) list
    (** Fetches a row and return it as an association list of pairs
      * (column name, value).
      * @raise Not_found if there are no more rows to fetch. *)

  method virtual serial : string -> int
    (** If the statement is an INSERT and has been executed, then some
      * databases support retrieving the serial number of the INSERT
      * statement (assuming there is a SERIAL column or SEQUENCE attached
      * to the table). The string parameter is the sequence name, which
      * is only required by some database types. See the specific documentation
      * for your database for more information.
      * @raise Not_found if the serial number is not available.
      * @raise Failure if [#execute] has not been issued before.  *)

  method finish : unit -> unit
    (** "Finishes" the statement. This basically just frees up any memory
      * associated with the statement (this memory would be freed up by the
      * GC later anyway). After calling [#finish] you may call [#execute] to
      * begin executing another query.
      *)

  method connection : connection
    (** Return the database handle associated with this statement handle. *)
end

and virtual connection :
  ?host:string ->
  ?port:string ->
  ?user:string ->
  ?password:string ->
  string ->
object
  (** {2 Connection managment & information} *)

  method id : int
    (** Returns a unique integer which can be used to identify this
      * connection.
      *)

  method close : unit -> unit
    (** Closes the database handle. All statement handles are also invalidated.
      * Database handles which are collected by the GC are automatically
      * closed, but you should explicitly close handles to save resources,
      * where possible.
      *)

  method closed : bool
    (** Returns [true] if this database handle has been closed. Subsequent
      * operations on the handle will fail.
      *)

  method ping : unit -> bool
    (** This uses some active method to verify that the database handle is
      * still working. By this I mean that it tries to execute some sort of
      * 'null' statement against the database to see if it gets a response.
      * If the database is up, it returns [true]. If the database is down or
      * unresponsive, it returns [false]. This method should never throw
      * an exception (unless, perhaps, there is some sort of catastrophic
      * internal error in the [Dbi] library or the driver).
      *)

  method host : string option
    (** Return the [host] parameter. *)
  method port : string option
    (** Return the [port] parameter. *)
  method user : string option
    (** Return the [user] parameter. *)
  method password : string option
    (** Return the [password] parameter. *)
  method database : string
    (** Return the database name. *)

  method virtual database_type : string
    (** Database type (e.g. "postgres"). *)

  method set_debug : bool -> unit
    (** Use this to enable debugging on the handle. In this mode significant
      * events (such as executing queries) are printed out on stderr.
      *)

  method debug : bool
    (** Returns true if this handle has debugging enabled. *)


  (** {2 Database creation, destruction & connection} *)

(* TODO *)

  (** {2 Statement preparation} *)

  method virtual prepare : string -> statement
    (** Prepare a database query, and return the prepared statement.
      * The statement may contain [?] placeholders which can be substituted
      * for values when the statement is executed.
      *)

  method prepare_cached : string -> statement
    (** This method is identical to [prepare] except that, if possible, it
      * caches the statement handle with the database object. Future calls
      * with the same query string return the previously prepared statement.
      * For databases which support prepared statement handles, this avoids
      * a round-trip to the database, and an expensive recompilation of the
      * statement.
      *)

  method ex : string -> sql_t list -> statement
    (** [dbh#ex stm args] is a shorthand for
     {[ let sth = dbh#prepare_cached stmt in
      * sth#execute args;
      * sth
      * ]}
      *)

  (** {2 Commit and rollback} *)

  method commit : unit -> unit
    (** Perform a COMMIT operation on the database. *)

  method rollback : unit -> unit
    (** Perform a ROLLBACK operation on the database. *)

  method register_precommit : (unit -> unit) -> precommit_handle
    (** Register a function which will be called just BEFORE a commit
      * happens on this handle. This method returns a handle which can
      * be used to deregister the callback later. This is useful for
      * implementing various types of persistence.
      *)

  method unregister_precommit : precommit_handle -> unit
    (** Unregister a precommit callback. *)

  method register_postrollback : (unit -> unit) -> postrollback_handle
    (** Register a function which will be called just AFTER a rollback
      * happens on this handle. This method returns a handle which can
      * be used to deregister the callback later. This is useful for
      * implementing various types of persistence.
      *)

  method unregister_postrollback : postrollback_handle -> unit
    (** Unregister a postrollback callback. *)
end


module Factory :
sig
  val connect : string ->
    ?host:string -> ?port:string -> ?user:string -> ?password:string ->
    string -> connection
    (** Connect to a specific type of database.  The first string parameter
      * is the database type, eg. "postgres", "mysql", etc.
      *
      * @raise Invalid_argument if the database type is not known.
      * May throw other connection-specific SQL errors.
      *)

  val database_types : unit -> string list
    (** Returns a list of registered database types. *)

  val register : string ->
    (?host:string -> ?port:string -> ?user:string -> ?password:string ->
      string -> connection)
    -> unit
    (** Specific database drivers register themselves on load (or
      [Dynlink]) by calling this function.  The first argument is the
      database type (usually the name of the database engine) and the
      second is the connection function. *)
end
