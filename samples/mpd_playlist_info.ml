open Sys
open Unix

(* compile with
 * ocamlfind ocamlc -o mpd_playlist_info -package str,unix -linkpkg -g mpd_responses.ml mpd.ml mpd_playlist_info.ml
 * or
 * ocamlfind ocamlc -o mpd_playlist_info -package str,unix,libmpdclient -linkpkg -g mpd_playlist_info.ml
 *)
let host = "127.0.0.1"
let port = 6600

let () =
   let connection = Mpd.Connection.initialize host port in
   let client = Mpd.Client.initialize connection in
   match Mpd.Queue.playlist client with
   | Mpd.Queue.PlaylistError message -> print_endline message
   | Mpd.Queue.Playlist playlist -> let n = List.length playlist in
   print_endline ("Number of songs : " ^ (string_of_int n));
   List.iter (fun song ->
     let id = string_of_int (Song.id song) in
     let title = Song.title song in
     let album = Song.album song in
     print_endline (String.concat " " ["\t*"; id; title; album])) playlist;
   Mpd.Connection.close connection
