(*
 * Copyright 2017 Cedric LE MOIGNE, cedlemo@gmx.com
 * This file is part of OCaml-libmpdclient.
 *
 * OCaml-libmpdclient is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * any later version.
 *
 * OCaml-libmpdclient is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with OCaml-libmpdclient.  If not, see <http://www.gnu.org/licenses/>.
 *)

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
   match MpdQueue.playlist client with
   | MpdQueue.PlaylistError message -> print_endline message
   | MpdQueue.Playlist playlist -> let n = List.length playlist in
   print_endline ("Number of songs : " ^ (string_of_int n));
   List.iter (fun song ->
     let id = string_of_int (Song.id song) in
     let title = Song.title song in
     let album = Song.album song in
     print_endline (String.concat " " ["\t*"; id; title; album])) playlist;
   Mpd.Connection.close connection
