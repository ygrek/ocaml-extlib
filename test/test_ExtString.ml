(*
 * ExtLib Testing Suite
 * Copyright (C) 2004 Janne Hellsten
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

let t_starts_with () = 
  let s0 = "foo" in
  assert (S.starts_with s0 s0);
  assert (S.starts_with s0 "f");
  assert (not (S.starts_with s0 "bo"));
  assert (not (S.starts_with "" "foo"));
  assert (S.starts_with s0 "");
  assert (S.starts_with "" "")

let t_ends_with () = 
  let s0 = "foo" in
  assert (S.ends_with s0 "foo");
  assert (S.ends_with s0 "oo");
  assert (S.ends_with s0 "o");
  assert (S.ends_with s0 "");
  assert (S.ends_with "" "");
  assert (not (S.ends_with "" "b"));
  assert (not (S.ends_with s0 "f"))

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
    let s' = String.replace_chars 
               (fun c -> if c = '|' then "_" else String.of_char c) s in
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

let t_replace1 () =
  let s = "karhupullo" in
  assert (String.replace s "karhu" "kalja" = (true, "kaljapullo"));
  assert (String.replace s "kalja" "karhu" = (false, s));
  (* TODO is this correct?  Is "" supposed to always match? *)
  assert (String.replace s "" "karhu" = (true, "karhu"^s));
  assert (String.replace "" "" "karhu" = (true, "karhu"))

let t_strip () = 
  let s = "1234abcd5678" in
  assert (S.strip ~chars:"" s = s);
  assert (S.strip ~chars:"1" s = String.sub s 1 (String.length s-1));
  assert (S.strip ~chars:"12" s = String.sub s 2 (String.length s-2));
  assert (S.strip ~chars:"1234" s = "abcd5678");
  assert (S.ends_with (S.strip ~chars:"8" s) "567");
  assert (S.ends_with (S.strip ~chars:"87" s) "56");
  assert (S.ends_with (S.strip ~chars:"86" s) "567");
  assert (S.ends_with (S.strip ~chars:"" s) "5678")

let t_nsplit () =
  let s = "testsuite" in
  assert (S.nsplit s "t" = ["";"es";"sui";"e"]);
  assert (S.nsplit s "te" = ["";"stsui";""]);
  assert (try let _ = S.nsplit s "" in false with Invalid_string -> true)

let () = 
  Util.register "ExtString" [
    "starts_with", t_starts_with;
    "ends_with", t_ends_with;
    "map", t_map;
    "lchop", t_lchop;
    "rchop", t_rchop;
    "split", t_split;
    "replace_1", t_replace1;
    "strip", t_strip;
    "nsplit", t_nsplit;
  ]
