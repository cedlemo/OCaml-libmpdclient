open Sys
open Unix

(* compile with
 * ocamlfind ocamlc -o mpd_status_query -package str,unix -linkpkg -g mpd_responses.ml mpd.ml mpd_status_query.ml
 * or
 * ocamlfind ocamlc -o mpd_status_query -package str,unix,libmpdclient -linkpkg -g mpd_status_query.ml
 *)
let host = "127.0.0.1"
let port = 6600

let () =
   let connection = Mpd.Connection.initialize host port in
   print_endline ("received: " ^ (Mpd.Client.read connection));
   Mpd.Client.write connection ("status\n");
   let status = Mpd.Client.read_lines connection in
   let rec display_infos = function
     | [] -> Mpd.Connection.close connection
     | h :: q -> let _ = print_endline ("*>" ^ h) in display_infos q
   in display_infos status
