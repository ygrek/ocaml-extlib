(* Module ExtLib
	(c)2003 Nicolas Cannasse

	Note:
	
	Since ExtLib is provided for namespace convenience for
	users who wants to keep the usage of the original
	Ocaml Standard Library, no CMI nor documentation will
	be provided for this module.

	Users can simply do an "open ExtLib" to import all Ext*
	namespaces instead of doing "open ExtList" for example.
*)

module ExtList = ExtList.List
module ExtArray = ExtArray.Array
module ExtString = ExtString.String
module ExtHashtbl = ExtHashtbl.Hashtbl

include Std