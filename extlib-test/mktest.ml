(* This program generates the test harness *)
(* This program must be executed from the directory

   extlib-test

   and extlib itself must be located in the directory

   extlib-dev
*)

module F = Filename
module P = Printf

(* Step 1: find a list of all ExtLib modules *)

let extlib_dev_dir = 
  Filename.concat Filename.parent_dir_name "extlib-dev"

let build_dir = "build-tmp"

let build_dir_name = Filename.concat build_dir

let mtest_filename module_name ext = "mtest_"^module_name^ext

let itest_filename auth mname test ext = "itest_"^auth^"_"^mname^"_"^test^ext

(* PORTABILITY WARNING: this is the only place Unix module is used *)
let mkdir f = 
  try Unix.mkdir f 0o777  with _ -> ()


(* Get all the files in a directory as a list, the names do not
   include the directory pathname *)
let find_files dirname = 
  Array.to_list (Sys.readdir dirname)

(* Filter a list of strings with a regular expression *)
let filter_files rexp files =
  let crexp = Str.regexp rexp in
  List.filter
  (fun s -> Str.string_match crexp s 0)
  files


(* Regexp for finding *.mli files *)
let mli_re = "^.+\\.mli$"


(* Regexp for eliding .mli extension *)
let mli_rex = "^\\(.+\\)\\.mli$"


(* Find the modules in a directory, assuming each .mli file represents
   a module. The names are have leading character capitalised. *)
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


(* Now make the top level test harness *)
let mk_top all_modules =
  let f = open_out (build_dir_name "extlib_test.ml") in

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


(* Now make the individual module tests *)

(* Regexp for finding test files *)
let tst_re = "^test_.+_.+_.+\\.ml$"


(* Regexp for decoding test names *)
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
  let f = open_out (build_dir_name (mtest_filename mname ".ml")) in
  P.fprintf f "let test() = \n";

  let tests = Hashtbl.find_all all_tests mname in
  P.fprintf f "  Util.test_module \"%s\"\n    (fun () ->\n" mname;
  List.iter
    (fun (author,test) ->
       P.fprintf f
       "      Itest_%s_%s_%s.test ();\n" author mname test) tests;
  P.fprintf f "      ())\n";
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
  let output_filename = build_dir_name (itest_filename author mname test ".ml") in
  copy_file input_filename output_filename

  
let patch_tests all_tests =
  Hashtbl.iter
  (fun mname (author,test) -> 
    patch_test mname author test
  )
  all_tests


let exec cmd msg =
  let result = Sys.command cmd in
  if result != 0
  then 
    failwith ("FAILURE: msg=" ^ msg ^ ", cmd=" ^cmd)


let ocaml_cmd = function
    `CompileByte -> "ocamlc -g"
  | `CompileNative -> "ocamlopt"

let compile_file build_type filename =
  let cmd = (ocaml_cmd build_type)^" -I "^extlib_dev_dir^
    " -I " ^ build_dir ^
    " -I " ^ Filename.current_dir_name ^
    " -c " ^ filename 
  in
  print_endline cmd;
  exec cmd ("Compilation of " ^ filename)


let compile_tests build_type all_modules all_tests =
  (* compile individual tests *)
  Hashtbl.iter
  (fun mname (author,test) ->
    let filename = build_dir_name (itest_filename author mname test ".ml") in
    compile_file build_type filename
  )
  all_tests
  ;
  (* compile generated module level thunks *)
  List.iter
  (fun s ->
    let filename = build_dir_name (mtest_filename s ".ml") in
    compile_file build_type filename
  )
  all_modules
  ;
  (* compile mainline *)
  compile_file build_type (build_dir_name "extlib_test.ml")




let link_tests build_type all_modules all_tests =
  let (obj_ext,lib_ext) = 
    match build_type with
      `CompileByte -> (".cmo",".cma")
    | `CompileNative -> (".cmx", ".cmxa") in
  (* Individual tests *)
  let linkstring =
    P.sprintf "%s -I %s -I %s -I %s -o extlib_test extLib%s util%s"
      (ocaml_cmd build_type) extlib_dev_dir build_dir 
      (Filename.current_dir_name) lib_ext obj_ext in
  let test_o_files = 
    String.concat " " 
      (Hashtbl.fold (fun mname (auth,test) accu ->
                       itest_filename auth mname test obj_ext::accu)
         all_tests []) in
  let mid_o_files = 
    String.concat " " 
      (List.map (fun s -> mtest_filename s obj_ext) all_modules) in
  (* Compile mainline *)
  let link_cmd = linkstring ^ " " ^ test_o_files ^ " " ^ mid_o_files ^ " " ^
                 (build_dir_name "extlib_test"^obj_ext) in
  print_endline link_cmd;
  exec link_cmd "Linking extlib_test"

exception InvalidArg of string
(* Extract args of the form --foobar or --foo=bar *)
let parse_options () =
  let options = 
    [(`OptArg, "author", "Use only tests made by the specified author");
     (`OptToggle, "opt", "Compile native code (default is bytecode)")] in
  let print_usage () = 
    P.fprintf stderr "Usage: %s [options]\n" (F.basename Sys.argv.(0));
    List.iter
      (fun ((_,_,desc) as opt) ->
         let opt_str = function
             (`OptArg,opt_name,_) -> ("--"^opt_name^"=<value>")
           | (`OptToggle,opt_name,desc) -> ("--"^opt_name) in
         P.fprintf stderr "  %-22s      %s\n" (opt_str opt) desc) options in
  let args = ref [] in
  let assign_re = Str.regexp "^--\\([A-Za-z]+\\)=\\(.*\\)$" in
  let toggle_re = Str.regexp "^--\\([A-Za-z]+\\)$" in
  let opt_exists opt = List.exists (function (_,f,_) -> f = opt) in
  let toggles = List.filter (function (`OptToggle,_,_) -> true | _ -> false) options
  and assigns = List.filter (function (`OptArg,_,_) -> true | _ -> false) options in
  for i = 1 to Array.length Sys.argv - 1 do
    let a = Sys.argv.(i) in
    try 
      if Str.string_match assign_re a 0
      then
        begin
          let opt_name = Str.matched_group 1 a in
          if not (opt_exists opt_name assigns) then
            raise (InvalidArg ("Unknown assignment option '"^opt_name^"'"));
          args := (opt_name, Str.matched_group 2 a) :: !args
        end
      else if Str.string_match toggle_re a 0 then
        begin
          let opt_name = Str.matched_group 1 a in
          if not (opt_exists opt_name toggles) then
            raise (InvalidArg ("Unknown toggle option '"^opt_name^"'"));
          args := (opt_name, "") :: !args;
        end
      else
        raise (InvalidArg ("Invalid command line syntax in '"^a^"'"))
    with InvalidArg s -> 
      P.fprintf stderr "%s\n" s;
      print_usage ();
      exit 1
  done;
  !args
  
let main =
  let option_list = parse_options () in
  let author_selection = List.mem_assoc "author" option_list in
  let build_type = 
    if List.mem_assoc "opt" option_list then `CompileNative else `CompileByte in

  mkdir build_dir;

  let all_modules = (modules_of extlib_dev_dir) in
  let all_tests =
    let all_tests = (tests_of Filename.current_dir_name) in
    if author_selection then 
      begin
        let selected_tests = Hashtbl.create 97 in
        Hashtbl.iter
          (fun mname (author,test) ->
             if List.mem ("author",author) option_list
             then Hashtbl.add selected_tests mname (author,test)) all_tests;
        selected_tests
      end
    else all_tests
  in

  print_endline "Modules:";
  print_endline (String.concat "\n" (List.map ((^) "  ") all_modules));

  print_endline "\nTests:";
  Hashtbl.iter
    (fun mname (author,test) -> 
       print_endline ("  test_"^author^"_"^mname^"_"^test)) all_tests;
  print_endline "";

  mk_top all_modules;
  mk_mtests all_modules all_tests;
  patch_tests all_tests;

  copy_file "util.ml" (build_dir_name "util.ml");
  compile_file build_type (build_dir_name "util.ml");
  compile_tests build_type all_modules all_tests;
  link_tests build_type all_modules all_tests;
  print_endline "extlib_test generated"
