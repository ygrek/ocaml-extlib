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

let test () = 
  Util.run_test ~test_name:"jh_Dllist.test_simple" test_simple
