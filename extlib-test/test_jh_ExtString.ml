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

open ExtString

module S = String

let t_starts_with () = 
  let s0 = "foo" in
  assert (S.starts_with s0 s0);
  assert (S.starts_with s0 "f");
  assert (not (S.starts_with s0 "bo"));
  assert (not (S.starts_with "" "foo"))

let t_map () =
  let s0 = "foobar" in
  assert (S.map Std.identity s0 = s0)

let t_lchop () =
  for len = 0 to 15 do
    let s0 = Util.random_string_len len in
    let s0len = String.length s0
    and s0r = ref (String.copy s0) in
    for i = 0 to s0len-1 do
      assert (!s0r.[0] = s0.[i]);
      s0r := String.lchop !s0r
    done;
  done

let t_rchop () =
  for len = 0 to 15 do
    let s0 = Util.random_string_len len in
    let s0len = String.length s0
    and s0r = ref (String.copy s0) in
    for i = 0 to s0len-1 do
      assert (!s0r.[String.length !s0r - 1] = s0.[s0len-1-i]);
      s0r := String.rchop !s0r
    done;
  done

let t_split () = 
  for i = 0 to 64 do
    let s = Util.random_string () in
    let s' = String.replace_chars (fun c -> if c = '|' then "_" else String.of_char c) s in
    let len = String.length s' in
    if len > 0 then
      begin
        let rpos = Random.int len in
        (* Insert separator and split based on that *)
        s'.[rpos] <- '|';
        let (half1, half2) = String.split s' "|" in
        if rpos > 1 then
          begin
            assert (String.length half1 = rpos);
            assert (String.sub s' 0 rpos = half1)
          end;
        if rpos < len-1 then
          begin
            assert (String.length half2 = len-rpos-1);
            assert (String.sub s' (rpos+1) (len-rpos-1) = half2);
          end;
        assert (String.join "|" [half1; half2] = s');
      end
  done

let test () = 
  Util.run_test ~test_name:"jh_ExtString.t_starts_with" t_starts_with;
  Util.run_test ~test_name:"jh_ExtString.t_map" t_map;
  Util.run_test ~test_name:"jh_ExtString.t_lchop" t_lchop;
  Util.run_test ~test_name:"jh_ExtString.t_rchop" t_rchop;
  Util.run_test ~test_name:"jh_ExtString.t_split" t_split
