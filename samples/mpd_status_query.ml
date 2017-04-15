(*
 * Copyright 2017 Cedric LE MOIGNE, cedlemo@gmx.com
 * This file is part of OCaml-libmpdclient.
 *
 * Topinambour is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * any later version.
 *
 * Topinambour is distributed in the hope that it will be useful,
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
 * ocamlfind ocamlc -o mpd_status_query -package str,unix -linkpkg -g mpd_responses.ml mpd.ml mpd_status_query.ml
 * or
 * ocamlfind ocamlc -o mpd_status_query -package str,unix,libmpdclient -linkpkg -g mpd_status_query.ml
 *)
let host = "127.0.0.1"
let port = 6600

let () =
   let connection = Mpd.Connection.initialize host port in
   print_endline ("received: " ^ (Mpd.Connection.read connection));
   Mpd.Connection.write connection ("status\n");
   let status = Mpd.Connection.read connection in
   let lines = Mpd.Utils.split_lines status in
   let rec display_infos = function
     | [] -> Mpd.Connection.close connection
     | h :: q -> let _ = print_endline ("*>" ^ h) in display_infos q
   in display_infos lines
