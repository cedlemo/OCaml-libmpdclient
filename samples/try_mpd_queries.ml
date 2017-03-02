open Sys
open Unix

(* compile with
 * ocamlfind ocamlc -o try_mpd_queries -package str,unix -linkpkg -g mpd_responses.ml mpd.ml try_mpd_queries.ml
 * or
 * ocamlfind ocamlc -o try_mpd_queries -package str,unix,libmpdclient -linkpkg -g try_mpd_queries.ml
 *)
let host = "127.0.0.1"
let port = 6600

let () =
   let connection = Mpd.Connection.initialize host port in
   print_endline ("received: " ^ (Mpd.Connection.read connection));
   Mpd.Connection.write connection (Sys.argv.(1) ^"\n");
   print_endline ("received: " ^ (Mpd.Connection.read connection));
   Mpd.Connection.close connection;
