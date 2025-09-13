let locality : string =
  {|(* Read more about OxCaml at: https://blog.janestreet.com/oxidizing-ocaml-locality *)
open Base

let is_empty (s : string @ local) =
 String.length s = 0

let () = 
  let msg : string @ local = "Hello, OxCaml!" in
  if not (is_empty msg) then
    Stdlib.print_endline msg
|}
