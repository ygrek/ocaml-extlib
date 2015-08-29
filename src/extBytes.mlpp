#if defined OCAML4_02 || defined WITH_BYTES
module Bytes = Bytes
#else
module Bytes = struct

include String

let empty = ""
let of_string = copy
let to_string = copy

let sub_string = sub
let blit_string = blit

let unsafe_to_string : t -> string = fun s -> s
let unsafe_of_string : string -> t = fun s -> s

end
#endif
