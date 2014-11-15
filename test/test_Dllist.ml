(*
 * ExtLib Testing Suite
 * Copyright (C) 2004 Janne Hellsten
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

let test_simple () = 
  for i = 1 to 5 do
    let rec make_lst accu n = 
      if n < i then make_lst (i::accu) (n+1)
      else accu in
    let lst = make_lst [] 0 in
    let dlst = Dllist.of_list lst in
    assert (List.length lst = Dllist.length dlst);
    List.iter 
      (fun e -> 
         let dl_elem = Dllist.get dlst in
         assert (e = dl_elem);
         Dllist.remove dlst) lst;
  done

(* Failure case reported by Christopher Wedman on extlib mailing list 2005/Feb/12.  *)
let test_regression_1 () = 
  let lst = Dllist.create 1 in
  ignore (Dllist.append lst 2);
  ignore (Dllist.demote lst);
  ignore (Dllist.length lst) (* <-- hangs here *)

(* Failure case reported by Christopher Wedman on extlib mailing list 2005/Feb/12.  *)
let test_regression_2 () = 
  let lst = Dllist.create 1 in
  ignore (Dllist.append lst 2);
  ignore (Dllist.promote lst);
  assert (Dllist.length lst = 2)  (* returned 1, but should return 2 *)

let () = 
  Util.register "Dllist" [
    "simple", test_simple;
    "regression_1", test_regression_1;
    "regression_2", test_regression_2;
  ]
