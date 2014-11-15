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

let in_range c a b = 
  let i = int_of_char c 
  and ai = int_of_char a 
  and bi = int_of_char b in
  (i >= ai && i <= bi)

let check_chars s =
  let len = String.length s in
  if len > 0 then
    begin
      for i = 0 to len-1 do
        let c = s.[i] in
        if not (in_range c 'A' 'Z') then
          if not (in_range c 'a' 'z') then
            if not (in_range c '0' '9') then
              assert (c = '/' || c = '+')
      done
    end

let () =
  Util.register1 "Base64" "random"
    (fun () -> 
       for i = 0 to 64 do
         let s = Util.random_string () in
         let enc = Base64.str_encode s in
         assert ((Base64.str_decode enc) = s);
         check_chars enc
       done)
