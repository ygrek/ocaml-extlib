(* This program generates the test harness *)
(* This program must be executed from the directory

   extlib-test

   and extlib itself must be located in the directory

   extlib-dev
*)

(* Step 1: find a list of all ExtLib modules *)

let extlib_dev_dir = 
  Filename.concat Filename.parent_dir_name "extlib-dev"


let build_dir = "build-tmp"


(* PORTABILITY WARNING: this is the only place Unix module is used *)
let mkdir f = 
  try Unix.mkdir f 0o777  with _ -> ()


(* get all the files in a directory as a list, the names
  do not include the directory pathname
*)
let find_files dirname = 
  Array.to_list (Sys.readdir dirname)

(* filter a list of strings with a regular expression *)
let filter_files rexp files =
  let crexp = Str.regexp rexp in
  List.filter
  (fun s -> Str.string_match crexp s 0)
  files


(* regexp for finding *.mli files *)
let mli_re = "^.+\\.mli$"


(* regexp for eliding .mli extension *)
let mli_rex = "^\\(.+\\)\\.mli$"


(* find the modules in a directory, assuming
each .mli file represents a module. The names
are have leading character capitalised.
*)

let modules_of dirname =
  let crexp = Str.regexp mli_rex in
  List.map
  (fun s-> 
    ignore(Str.string_match crexp s 0); 
    let s = Str.matched_group 1 s in
    s.[0] <- Char.uppercase s.[0];
    s
  )
  (filter_files mli_re (find_files dirname))


(* now make the top level test harness *)
let mk_top all_modules =
  let f = open_out (Filename.concat build_dir "extlib_test.ml") in

  output_string f "let main() = \n";
  output_string f "  Util.log \"ExtLib tester started\";\n";
  List.iter
  (fun s->
    output_string f ("  Mtest_" ^ s ^ ".test ();\n")
  )
  all_modules
  ;
  output_string f "  Util.log \"ExtLib tests completed\"\n";
  output_string f "\n";
  output_string f ";;\n";
  output_string f "main();;\n";
  close_out f


(* now make the individual module tests *)

(* regexp for finding test files *)
let tst_re = "^test_.+_.+_.+\\.ml$"


(* regexp for decoding test names *)
let tst_rex = "^test_\\(.+\\)_\\(.+\\)_\\(.+\\)\\.ml$"



let tests_of dirname =
  let h = Hashtbl.create 97 in
  let crexp = Str.regexp tst_rex in
  List.iter
  (fun s-> 
    ignore(Str.string_match crexp s 0); 
    let author_key = Str.matched_group 1 s in
    let module_key = Str.matched_group 2 s in
    let test_key = Str.matched_group 3 s in
    Hashtbl.add h module_key (author_key,test_key)
  )
  (filter_files tst_re (find_files dirname));
  h


let mtest all_tests mname =
  let f = open_out (Filename.concat build_dir ("mtest_" ^ mname ^ ".ml")) in

  output_string f "let test() = \n";

  let tests = Hashtbl.find_all all_tests mname in
  output_string f ("  Util.log \"Checking module " ^ mname ^ "\";\n");
  List.iter
  (fun (author,test) ->
    output_string f ("  Itest_" ^ author ^ "_" ^mname^"_"^test^".test ();\n")
  )
  tests
  ;
  output_string f "  ()\n";
  output_string f "\n";
  close_out f


let mk_mtests all_modules all_tests = 
  List.iter (mtest all_tests) all_modules


let copy_file fin fout =
  let fi = open_in fin in
  let fo = open_out fout in
  let rec loop() =
    let s = input_line fi in
    output_string fo (s ^ "\n");
    loop()
  in try loop() with End_of_file ->
  output_string fo "\n";
  close_out fo;
  close_in fi


let patch_test mname author test =
  let input_filename = "test_" ^ author ^ "_" ^mname^"_"^test^".ml" in
  let output_filename = Filename.concat build_dir ("itest_" ^ author ^ "_" ^mname^"_"^test^".ml") in
  copy_file input_filename output_filename

  
let patch_tests all_tests =
  Hashtbl.iter
  (fun mname (author,test) -> 
    patch_test mname author test
  )
  all_tests


let xqt cmd msg =
  let result = Sys.command cmd in
  if result != 0
  then 
    failwith ("FAILURE: msg=" ^ msg ^ ", cmd=" ^cmd)


let compile_file filename =
  let cmd = "ocamlc -I "^extlib_dev_dir^
    " -I " ^ build_dir ^
    " -I " ^ Filename.current_dir_name ^
    " -c " ^ filename 
  in
  print_endline cmd;
  xqt cmd ("Compilation of " ^ filename)


let compile_tests all_modules all_tests =
  (* compile individual tests *)
  Hashtbl.iter
  (fun mname (author,test) ->
    let filename = Filename.concat build_dir ("itest_" ^ author ^ "_" ^mname^"_"^test^".ml") in
    compile_file filename
  )
  all_tests
  ;
  (* compile generated module level thunks *)
  List.iter
  (fun s ->
    let filename = Filename.concat build_dir ("mtest_" ^ s ^ ".ml") in
    compile_file filename
  )
  all_modules
  ;
  (* compile mainline *)
  compile_file (Filename.concat build_dir "extlib_test.ml")




let link_tests all_modules all_tests =
  (* individual tests *)
  let linkstring = ref (
    "ocamlc" ^
    " -I "^extlib_dev_dir ^
    " -I "^build_dir ^
    " -I "^Filename.current_dir_name ^
    " -o extlib_test extLib.cma util.cmo " 
  )
  in 
  Hashtbl.iter
  (fun mname (author,test) ->
    let filename = "itest_" ^ author ^ "_" ^mname^"_"^test^".cmo" in
    linkstring := !linkstring ^ " " ^ filename
  )
  all_tests
  ;
  (* compile generated module level thunks *)
  List.iter
  (fun s ->
    let filename = "mtest_" ^ s ^ ".cmo" in
    linkstring := !linkstring ^ " " ^ filename
  )
  all_modules
  ;
  (* compile mainline *)
  linkstring := !linkstring ^ " " ^ 
  Filename.concat build_dir "extlib_test.cmo"
  ;
  xqt !linkstring "Linking extlib_test"


(* extract args of the form --xxxx=yyyy *)
let parse_options () =
  let args = ref [] in
  let re = Str.regexp "^--\\([A-Za-z]+\\)=\\(.*\\)$" in
  for i = 1 to Array.length Sys.argv - 1 do
    let a = Sys.argv.(i) in
    if Str.string_match re a 0
    then 
      args := (Str.matched_group 1 a, Str.matched_group 2 a) :: ! args
    else failwith ("Invalid option '"^a^"', use --author=initials")
  done;
  !args
  
let main() =
  let option_list = parse_options () in
  let author_selection = List.mem_assoc "author" option_list in

  mkdir build_dir;

  let all_modules = (modules_of extlib_dev_dir) in
  let all_tests =
    let all_tests = (tests_of Filename.current_dir_name) in
    if author_selection then begin
      let selected_tests = Hashtbl.create 97 in
      Hashtbl.iter
      (fun mname (author,test) ->
        if List.mem ("author",author) option_list
        then Hashtbl.add selected_tests mname (author,test)
        else ();
      )
      all_tests;
      selected_tests
    end
    else all_tests
  in

  print_endline "Modules:";
  List.iter
  (fun s-> print_endline ("  " ^ s))
  all_modules
  ;
  print_endline "";

  print_endline "Tests:";
  Hashtbl.iter
  (fun mname (author,test) -> 
    print_endline ("  test_" ^ author ^ "_" ^ mname ^ "_"^ test)
  )
  all_tests
  ;
  print_endline "";

  mk_top all_modules;
  mk_mtests all_modules all_tests;
  patch_tests all_tests;

  copy_file "util.ml" (Filename.concat build_dir "util.ml");
  compile_file (Filename.concat build_dir "util.ml");

  compile_tests all_modules all_tests;
  link_tests all_modules all_tests;

  print_endline "extlib_test generated"
;;

main ()
;;

