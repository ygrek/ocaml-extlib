
let log s = 
  Printf.printf "%s\n" s

let random_char () = 
  char_of_int (Random.int 256)

let random_string () = 
  let len = Random.int 256 in
  let str = String.create len in
  if len > 0 then
    for i = 0 to (len-1) do
      str.[i] <- random_char ()
    done;
  str


let random_string_len len = 
  let len = len in
  let str = String.create len in
  if len > 0 then
    for i = 0 to (len-1) do
      str.[i] <- random_char ()
    done;
  str

let run_test ?(test_name="<unknown>") f = 
  try
    Printf.printf "\nrun: %s" test_name;
    flush stdout;
    f ();
  with 
    Assert_failure (file,line,column) ->
      Printf.printf " ..FAILED\n  reason:\n";
      Printf.printf "%s:%i:%i test %s failed\n" file line column test_name;
      flush stdout
