
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

let test () =
  Util.run_test ~test_name:"jh_Base64.test" 
    (fun () -> 
       for i = 0 to 64 do
         let s = Util.random_string () in
         let len = String.length s in
         let enc = Base64.str_encode s in
         assert ((Base64.str_decode enc) = s);
         check_chars enc
       done)
