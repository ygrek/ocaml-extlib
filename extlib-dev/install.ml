(*
 * Install - ExtLib installation * Copyright (C) 2003 Nicolas Cannasse
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
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
 
open Printf

type path =
	| PathUnix
	| PathDos

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

let obj_ext , lib_ext , cp_cmd , path_type = match Sys.os_type with
	| "Unix" | "Cygwin" | "MacOS" -> ".o" , ".a" , "cp", PathUnix
	| "Win32" -> ".obj" , ".lib" , "copy", PathDos
	| _ -> failwith "Unknown OS"		

let run cmd =
	prerr_endline cmd;
	let ecode = Sys.command cmd in
	if ecode <> 0 then failwith (sprintf "Exit Code %d - Stopped" ecode)

let copy file dest =
	if dest <> "" && dest <> "." then begin
		prerr_endline ("Installing "^file);
		let path = dest ^ file in
		(try Sys.remove path with _ -> ());
		try
			Sys.rename file path;
		with
			_ -> failwith "Aborted"
	end

let complete_path p =
	if p = "" then
		p
	else
		let c = p.[String.length p - 1] in
		if c = '/' || c = '\\' then
			p
		else
			p^(match path_type with PathUnix -> "/" | PathDos -> "\\")

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
	let dest = complete_path (read_line()) in
	(try
		close_out (open_out (dest^"test.file"));
		Sys.remove (dest^"test.file");
	with
		_ -> failwith ("Directory "^dest^" does not exists or cannot be written."));
	printf "Do you want to generate ocamldoc documentation (Y/N) ?\n> ";
	let doc = (match read_line() with
		| "y" | "Y" -> true
		| "n" | "N" -> false
		| _ -> failwith "Invalid choice, exit.");
	in
	if doc && not (Sys.file_exists "extlib-doc") then run (sprintf "mkdir %sextlib-doc" dest);
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
	if doc then begin 
		run (sprintf "ocamldoc -html -d %sextlib-doc %s" dest (m_list ".mli"));
		run ((match path_type with
				| PathDos -> sprintf "%s odoc_style.css %sextlib-doc\\style.css";
				| PathUnix -> sprintf "%s odoc_style.css %sextlib-doc/style.css") cp_cmd dest);
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


