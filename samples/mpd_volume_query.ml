open Sys
open Unix

(* compile with
 * ocamlfind ocamlc -o mpd_volume_query -package str,unix -linkpkg -g mpd_responses.ml mpd.ml mpd_volume_query.ml
 * or
 * ocamlfind ocamlc -o mpd_volume_query -package str,unix,libmpdclient -linkpkg -g mpd_volume_query.ml
 *)
let host = "127.0.0.1"
let port = 6600

let () =
   let connection = Mpd.Connection.initialize host port in
   print_endline ("received: " ^ (Mpd.Client.read connection));
   let s = Mpd.Client.status connection in
   let vol = Mpd.Client.volume s in
   print_endline (string_of_int vol);
   Mpd.Connection.close connection;
