(*
 * ExtLib Testing Suite
 * Copyright (C) 2011 ygrek
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

open ExtString

module S = String

let test_nsplit () =
  let s = "testsuite" in
  assert (S.nsplit s "t" = ["";"es";"sui";"e"]);
  assert (S.nsplit s "te" = ["";"stsui";""]);
  assert (try let _ = S.nsplit s "" in false with Invalid_string -> true)

let test () = 
  Util.run_test ~test_name:"y_ExtString_001.nsplit" test_nsplit;
  ()
