open Printf

let modules = [
	"enum";
	"bitSet";
	"dynArray";
	"extHashtbl";
	"extList";
	"extString";
	"global";
	"option";
	"refList";
	"std";
	"uChar";
	"uTF8"
]

let m_list suffix =
	String.concat " " (List.map (fun m -> m ^ suffix) modules)

let obj_ext , lib_ext = match Sys.os_type with
	| "Unix" | "Cygwin" | "MacOS" -> ".o" , ".a"
	| "Win32" -> ".obj" , ".lib"
	| _ -> failwith "Unknown OS"

let run cmd =
	prerr_endline cmd;
	let ecode = Sys.command cmd in
	if ecode <> 0 then failwith (sprintf "Exit Code %d - Stopped" ecode)

let copy file dest =
	prerr_endline ("Installing "^file);
	let path = dest ^ file in
	(try Sys.remove path with _ -> ());
	try
		Sys.rename file path;
	with
		_ -> failwith "Aborted"

let remove file =	
	try
		Sys.remove file
	with
		_ -> prerr_endline ("Warning : failed to delete "^file)

let install() =
	printf "ExtLib installation program v1.0\n(c)2003 Nicolas Cannasse\n";
	printf "Choose one of the following :\n1- Bytecode installation only\n2- Native installation only\n3- Both Native and Bytecode installation\n> ";
	let byte, native = (match read_line() with
		| "1" -> true, false
		| "2" -> false, true
		| "3" -> true, true
		| _ -> failwith "Invalid choice, exit.")
	in
	printf "Choose installation directory :\n> ";
	let dest = read_line() in
	if dest = "" then failwith "Empty directory - aborted.";
	let dest = (let c = dest.[String.length dest - 1] in if c = '/' || c = '\\' then dest else dest^"/") in
	(try
		close_out (open_out (dest^"test.file"));
		Sys.remove (dest^"test.file");
	with
		_ -> failwith ("Directory "^dest^" does not exists or cannot be written."));
	run (sprintf "ocamlc -c %s" (m_list ".mli"));
	if byte then begin
		List.iter (fun m -> run (sprintf "ocamlc -c %s.ml" m)) modules;
		run (sprintf "ocamlc -a -o extLib.cma %s extLib.ml" (m_list ".cmo"));
		List.iter (fun m -> remove (m^".cmo")) modules;
		remove "extLib.cmo";
	end;
	if native then begin
		List.iter (fun m -> run (sprintf "ocamlopt -c %s.ml" m)) modules;
		run (sprintf "ocamlopt -a -o extLib.cmxa %s extLib.ml" (m_list ".cmx"));
		List.iter (fun m -> remove (m^".cmx"); remove (m^obj_ext)) modules;
		remove "extLib.cmx";
		remove ("extLib"^obj_ext);
	end;
	List.iter (fun m -> copy (m^".cmi") dest) modules;
	copy "extLib.cmi" dest;
	if byte then copy "extLib.cma" dest;
	if native then begin
		copy "extLib.cmxa" dest;
		copy ("extLib"^lib_ext) dest;
	end

;;
try 
	install();
	printf "Done.";
with
	Failure msg ->
		prerr_endline msg;
		exit 1


