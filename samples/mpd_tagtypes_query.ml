open Sys
open Unix

(* compile with
 * ocamlfind ocamlc -o mpd_tagtypes_query -package str,unix -linkpkg -g mpd_responses.ml mpd.ml mpd_tagtypes_query.ml
 * or
 * ocamlfind ocamlc -o mpd_tagtypes_query -package str,unix,libmpdclient -linkpkg -g mpd_tagtypes_query.ml
 *)
let host = "127.0.0.1"
let port = 6600

let () =
   let connection = Mpd.Connection.initialize host port in
   let client = Mpd.Client.initialize connection in
   let tagtypes = Mpd.Client.tagtypes client in
   List.iter (fun x -> print_endline ("-*-" ^ x)) tagtypes;
