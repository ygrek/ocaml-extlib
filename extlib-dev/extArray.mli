module Array :
  sig

	val exists: ('a -> bool) -> 'a array -> bool
	val for_all: ('a -> bool) -> 'a array -> bool
	val find: ('a -> bool) -> 'a array -> 'a (* raise Not_found *)

  end
