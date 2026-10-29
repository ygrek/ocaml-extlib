(*
 * ExtLib Testing Suite
 * Copyright (C) 2004, 2007 Janne Hellsten
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

(* NOTE The IO module test case was contributed by Robert Atkey on
   ocaml-lib-devel@lists.sourceforge.net on Nov 26, 2007.
   Thanks Rob! *)

let fail fmt = Printf.ksprintf failwith fmt

let test_write_read values invalid show write read =
  let s = IO.output_string () in
  List.iter begin fun x ->
    if try write s x; true with IO.Overflow _ -> false then fail "write %s expected to fail, but didn't" (show x)
  end invalid;
  List.iter begin fun i ->
    try write s i with exn -> fail "failed to write %s : %s" (show i) (Printexc.to_string exn)
  end values;
  let s = IO.close_out s in
  let s = IO.input_string s in
  List.iter begin fun expect ->
    let i = read s in
    if i <> expect then fail "failed to read %s : got %s" (show expect) (show i)
  end values;
  match IO.read_all s with
  | "" -> ()
  | s -> fail "expected empty input, got %S" s

let test_i8 () =
  let values = [~-0x80;-1;0;1;0x7F] in
  let invalid = [] in (* never fails - truncates *)
  test_write_read values invalid string_of_int IO.write_byte IO.read_signed_byte;
  ()

let test_u8 () =
  let values = [0;1;0xFF] in
  let invalid = [] in (* never fails *)
  test_write_read values invalid string_of_int IO.write_byte IO.read_byte;
  ()

let test_i16 () =
  (* Bug was that write_i16 did not accept -0x8000 *)
  let values = [~-0x8000;-1;0;1;0x7FFF] in
  let invalid = [~-0x8001;0x8000] in
  let test = test_write_read values invalid string_of_int in
  test IO.write_i16 IO.read_i16;
  test IO.BigEndian.write_i16 IO.BigEndian.read_i16;
  ()

let test_u16 () =
  let values = [0;1;0xFFFF] in
  let invalid = [~-1;0x10000] in
  let test = test_write_read values invalid string_of_int in
  test IO.write_ui16 IO.read_ui16;
  test IO.BigEndian.write_ui16 IO.BigEndian.read_ui16;
  ()

let test_i31 () =
  let values = [~-0x4000_0000;-1;0;1;0x3FFF_FFFF] in
  let invalid = if Sys.word_size = 32 then [] else [~-0x4000_0001;0x4000_0000] in
  let test = test_write_read values invalid string_of_int in
  test IO.write_i31 IO.read_i31;
  test IO.BigEndian.write_i31 IO.BigEndian.read_i31;
  ()

let test_i32 () =
  let min_i32 = Int32.to_int Int32.min_int in
  let max_i32 = Int32.to_int Int32.max_int in
  let values = [~-0x4000_0000;-1;0;1;0x3FFF_FFFF] @ if Sys.word_size = 32 then [] else [min_i32;max_i32] in
  let invalid = if Sys.word_size = 32 then [] else [min_i32-1;max_i32+1] in
  let test = test_write_read values invalid string_of_int in
  test IO.write_i32 IO.read_i32_as_int;
  test IO.BigEndian.write_i32 IO.BigEndian.read_i32_as_int;
  ()

let test_real_i32 () =
  let values = [Int32.min_int;-1l;0l;1l;Int32.max_int] in
  let invalid = [] in
  let test = test_write_read values invalid Int32.to_string in
  test IO.write_real_i32 IO.read_real_i32;
  test IO.BigEndian.write_real_i32 IO.BigEndian.read_real_i32;
  ()

let test_bits () =
  let input = Bytes.make 4 (Char.chr 0xFF) in
  let ch = IO.input_bits (IO.input_bytes input) in
  let value = IO.read_bits ch 31 in
  assert (value = (0b111_1111_1111_1111_1111_1111_1111_1111));
  ()

(* -------------------------------------------------------------- *)
(* read_line *)

(* Semantics under test: lines end in LF or CRLF (the terminator is
   stripped); a CR not followed by LF is data and is kept, also at EOF;
   a final unterminated non-empty line is returned; at EOF with nothing
   pending, [No_more_input] is raised (so "a\n" is one line, not two). *)

(* Reference [read_line] on a plain string: the expected lines. *)
let expected_lines s =
  let n = String.length s in
  let rec go acc start =
    if start >= n then List.rev acc
    else match String.index_from_opt s start '\n' with
      | None -> List.rev (String.sub s start (n - start) :: acc)
      | Some j ->
        let stop = if j > start && s.[j-1] = '\r' then j - 1 else j in
        go (String.sub s start (stop - start) :: acc) (j + 1)
  in
  go [] 0

(* An [IO.input] with no [as_buffered]: exercises the byte-at-a-time path. *)
let unbuffered_input s =
  let pos = ref 0 in
  let n = String.length s in
  IO.create_in
    ~read:(fun () ->
      if !pos >= n then raise IO.No_more_input;
      let c = s.[!pos] in incr pos; c)
    ~input:(fun b p l ->
      if !pos >= n then raise IO.No_more_input;
      let k = min l (n - !pos) in
      Bytes.blit_string s !pos b p k;
      pos := !pos + k; k)
    ~close:ignore

(* A buffered input whose buffer is refilled [chunk] bytes at a time, in a
   buffer that is bigger than the chunk and padded with garbage, so that
   implementations relying on [Bytes.length buf] rather than [len], or on
   [refill] preserving old contents, get caught. *)
let chunked_input ~chunk s =
  let n = String.length s in
  let src = ref 0 in
  let buf_in = IO.Buf_in.create (Bytes.make (chunk + 5) '#') ~fill:(fun buf ->
    let k = min chunk (n - !src) in
    Bytes.fill buf 0 (Bytes.length buf) '#';
    Bytes.blit_string s !src buf 0 k;
    src := !src + k;
    k) in
  let read () =
    if buf_in.len = 0 then buf_in.refill ();
    let c = Bytes.get buf_in.buf buf_in.pos in
    IO.Buf_in.consume buf_in 1; c
  and input b p l =
    if buf_in.len = 0 then buf_in.refill ();
    let k = min l buf_in.len in
    Bytes.blit buf_in.buf buf_in.pos b p k;
    IO.Buf_in.consume buf_in k; k
  in
  IO.create_in_full ~read ~input ~close:ignore
    ~as_buffered:(fun () -> Some buf_in) ()

(* A buffered input whose data sits in the middle of a larger buffer
   ([pos > 0], garbage on both sides) and that has nothing to refill. *)
let offset_input s =
  let n = String.length s in
  let buf = Bytes.of_string ("GARBAGE\n" ^ s ^ "\nGARBAGE") in
  let buf_in = {
    IO.Buf_in.buf; pos = 8; len = n;
    refill = (fun () -> raise IO.No_more_input);
  } in
  let read () =
    if buf_in.len = 0 then raise IO.No_more_input;
    let c = Bytes.get buf buf_in.pos in
    IO.Buf_in.consume buf_in 1; c
  and input b p l =
    if buf_in.len = 0 then raise IO.No_more_input;
    let k = min l buf_in.len in
    Bytes.blit buf buf_in.pos b p k;
    IO.Buf_in.consume buf_in k; k
  in
  IO.create_in_full ~read ~input ~close:ignore
    ~as_buffered:(fun () -> Some buf_in) ()

let show_lines l = "[" ^ String.concat "; " (List.map (Printf.sprintf "%S") l) ^ "]"

(* Read lines until [No_more_input]. Then check that EOF is sticky. *)
let all_lines inp =
  (* cap: a broken read_line that never hits EOF must not loop forever *)
  let rec go n acc =
    if n > 20_000 then failwith "read_line never reached EOF";
    match IO.read_line inp with
    | l -> go (n + 1) (l :: acc)
    | exception IO.No_more_input -> List.rev acc
  in
  let lines = go 0 [] in
  match IO.read_line inp with
  | exception IO.No_more_input -> lines
  | l -> failwith (Printf.sprintf "read_line after EOF returned %S" l)

let read_line_cases = [
  (* trivial *)
  "";
  "\n"; "\n\n"; "\n\n\n";
  "a"; "a\n"; "a\nb"; "a\nb\n"; "a\n\nb"; "a\n\n";
  (* CRLF *)
  "\r\n"; "\r\n\r\n"; "a\r\n"; "a\r\nb"; "a\r\nb\r\n"; "a\r\n\r\nb";
  "a\r\n\n"; "a\n\r\n"; "a\r\nb\nc\r\n";
  (* lone CR is data *)
  "\r"; "a\r"; "a\rb\n"; "a\rb"; "\ra\n"; "a\n\rb"; "a\r\nb\r"; "a\n\r";
  (* several CRs in a row: only the last one belongs to a CRLF *)
  "\r\r"; "a\r\r"; "a\r\r\n"; "a\r\r\r\n"; "a\r\rb\n"; "a\r\r\rb"; "\r\r\n";
  "a\r\r\nb\r\r\n";
  (* other control chars and binary data are not special *)
  "\000\n"; "a\000b\n\255\r\n"; "\t \012\n"; "\n\r"; "a \r \n";
  (* long lines (longer than any initial buffer) *)
  String.make 10_000 'x';
  String.make 10_000 'x' ^ "\n";
  String.make 10_000 'x' ^ "\r\n" ^ String.make 100 'y' ^ "\r";
  String.make 5_000 '\r' ^ "\n";
]

(* Run every case on inputs made by [mk]; report all the mismatches at once
   instead of stopping at the first. *)
let check_read_lines ~what mk =
  let failures = ref [] in
  List.iter (fun s ->
    let expected = expected_lines s in
    let show_s = if String.length s > 40 then String.escaped (String.sub s 0 37) ^ "..." else String.escaped s in
    match all_lines (mk s) with
    | got when got = expected -> ()
    | got ->
      let short l = if String.length (show_lines l) > 120 then "<long>" else show_lines l in
      failures := Printf.sprintf "%s: input \"%s\": expected %s, got %s" what show_s (short expected) (short got) :: !failures
    | exception e ->
      failures := Printf.sprintf "%s: input \"%s\": exception %s" what show_s (Printexc.to_string e) :: !failures
  ) read_line_cases;
  match List.rev !failures with
  | [] -> ()
  | l ->
    List.iter (Printf.printf "\n    %s") l;
    print_newline ();
    assert false

let test_read_line_unbuffered () = check_read_lines ~what:"unbuffered" unbuffered_input
let test_read_line_input_string () = check_read_lines ~what:"input_string" IO.input_string
let test_read_line_input_bytes () =
  check_read_lines ~what:"input_bytes" (fun s -> IO.input_bytes (Bytes.of_string s))
let test_read_line_offset () = check_read_lines ~what:"offset buffer" offset_input

(* every chunk size, so that every case gets split at every possible place,
   in particular between a CR and the LF that follows it. *)
let test_read_line_chunked () =
  for chunk = 1 to 7 do
    check_read_lines ~what:(Printf.sprintf "chunk=%d" chunk) (chunked_input ~chunk)
  done;
  check_read_lines ~what:"chunk=64" (chunked_input ~chunk:64);
  check_read_lines ~what:"chunk=4096" (chunked_input ~chunk:4096)

(* A buffered input without any data at all (refill fails immediately). *)
let test_read_line_empty_buffered () =
  let inp = IO.input_string "" in
  assert (try ignore (IO.read_line inp); false with IO.No_more_input -> true);
  let inp = chunked_input ~chunk:3 "" in
  assert (try ignore (IO.read_line inp); false with IO.No_more_input -> true)

(* read_line interleaved with other readers: the buffered fast path must
   leave [pos]/[len] consistent for whoever reads next, and honour what
   others already consumed. *)
let test_read_line_mixed mk () =
  let inp = mk "xyz\nabc\r\ndef\r\nghi" in
  assert (IO.read inp = 'x');
  assert (IO.read_line inp = "yz");
  assert (IO.read inp = 'a');
  assert (IO.read_line inp = "bc");
  assert (Bytes.to_string (IO.nread inp 2) = "de");
  assert (IO.read_line inp = "f");
  assert (IO.read_line inp = "ghi");
  assert (try ignore (IO.read inp); false with IO.No_more_input -> true)

(* read_line stops right after the LF: the rest is still readable. *)
let test_read_line_leaves_rest mk () =
  let inp = mk "one\r\ntwo\nrest of it" in
  assert (IO.read_line inp = "one");
  assert (IO.read_line inp = "two");
  assert (IO.read_all inp = "rest of it")

(* A CR right before EOF, after a line was consumed from the same buffer. *)
let test_read_line_cr_then_read mk () =
  let inp = mk "a\r\nb\r" in
  assert (IO.read_line inp = "a");
  assert (IO.read_line inp = "b\r");
  assert (try ignore (IO.read_line inp); false with IO.No_more_input -> true)

(* Not read_line per se, but [input_bytes] is now backed by a [Buf_in.t]:
   check that plain reads keep it in sync. *)
let test_input_bytes_read_sync () =
  let inp = IO.input_string "ab" in
  assert (IO.read inp = 'a');
  assert (IO.read inp = 'b');
  assert (try ignore (IO.read inp); false with IO.No_more_input -> true);
  let inp = IO.input_string "abcd" in
  assert (IO.read inp = 'a');
  assert (IO.read_all inp = "bcd")

let test_buf_in_create () =
  let calls = ref 0 in
  let b = IO.Buf_in.create (Bytes.create 4) ~fill:(fun buf ->
    incr calls;
    if !calls = 1 then (Bytes.blit_string "xyz" 0 buf 0 3; 3) else 0) in
  assert (b.IO.Buf_in.len = 0);
  IO.Buf_in.refill_if_empty b;
  assert (b.IO.Buf_in.len = 3 && b.IO.Buf_in.pos = 0);
  IO.Buf_in.refill_if_empty b;  (* non-empty: no call *)
  assert (!calls = 1);
  IO.Buf_in.consume b 3;
  for _=1 to 3 do
    assert (try IO.Buf_in.refill_if_empty b; false with IO.No_more_input -> true)
  done;
  assert (!calls = 2);  (* EOF is sticky: fill not called again *)
  (* direct [refill] on a non-empty view is a no-op *)
  let c = ref 0 in
  let b2 = IO.Buf_in.create (Bytes.create 4) ~fill:(fun buf ->
    incr c; Bytes.blit_string "ab" 0 buf 0 2; 2) in
  b2.IO.Buf_in.refill ();
  b2.IO.Buf_in.refill ();
  assert (!c = 1 && b2.IO.Buf_in.len = 2);
  (* [fill] raising No_more_input is sticky too *)
  let d = ref 0 in
  let b3 = IO.Buf_in.create (Bytes.create 4)
    ~fill:(fun _ -> incr d; raise IO.No_more_input) in
  for _=1 to 3 do
    assert (try b3.IO.Buf_in.refill (); false with IO.No_more_input -> true)
  done;
  assert (!d = 1);
  let bad = IO.Buf_in.create (Bytes.create 2) ~fill:(fun _ -> 3) in
  assert (try bad.IO.Buf_in.refill (); false with Failure _ -> true)

let register_read_line () =
  let r = Util.register1 "IO" in
  r "read_line/unbuffered" test_read_line_unbuffered;
  r "read_line/input_string" test_read_line_input_string;
  r "read_line/input_bytes" test_read_line_input_bytes;
  r "read_line/offset_buffer" test_read_line_offset;
  r "read_line/chunked_refill" test_read_line_chunked;
  r "read_line/empty_buffered" test_read_line_empty_buffered;
  List.iter (fun (kind, mk) ->
    r ("read_line/mixed/" ^ kind) (test_read_line_mixed mk);
    r ("read_line/leaves_rest/" ^ kind) (test_read_line_leaves_rest mk);
    r ("read_line/cr_at_eof/" ^ kind) (test_read_line_cr_then_read mk))
    [ "unbuffered", unbuffered_input;
      "input_string", IO.input_string;
      "chunked1", chunked_input ~chunk:1;
      "chunked3", chunked_input ~chunk:3;
      "offset", offset_input ];
  r "input_bytes/read_sync" test_input_bytes_read_sync;
  r "Buf_in/create" test_buf_in_create

let register () =
  register_read_line ();
  Util.register1 "IO" "i32" test_i32;
  Util.register1 "IO" "real_i32" test_real_i32;
  Util.register1 "IO" "i31" test_i31;
  Util.register1 "IO" "u16" test_u16;
  Util.register1 "IO" "i16" test_i16;
  Util.register1 "IO" "u8" test_u8;
  Util.register1 "IO" "i8" test_i8;
  Util.register1 "IO" "bits" test_bits;
  ()
