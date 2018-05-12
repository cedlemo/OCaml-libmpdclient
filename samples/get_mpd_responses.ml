(*
 * Copyright 2018 Cedric LE MOIGNE, cedlemo@gmx.com
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
open Pervasives

(*
 * tool to get mpd response that will be used in tests
 * *)
let host = "127.0.0.1"
let port = 6600

let fd =
  let flags = [Open_trunc; Open_append; Open_creat] in
  let perm = 0o666 in
  Pervasives.open_out_gen flags perm "responses"

let write_down question response =
  let _ = Printf.fprintf fd "question -|%s|-\n" question in
  Printf.fprintf fd "response -|%s|-\n" response

let queries = ["ping";
               "stop";
               "playlist";
               "list Artist";
               "list Album artist Nile";
               "list Title artist Nile album Ithyphallic";]

let () =
  let connection = Mpd.Connection.initialize host port in
  let banner = Mpd.Connection.read connection in
  let _ = print_endline ("Server banner : " ^ banner) in
  let rec loop = function
    | [] -> Pervasives.close_out fd
    | q :: t ->
      let query = q ^ "\n" in
      let _ = Mpd.Connection.write connection query in
      let response = Mpd.Connection.read connection in
      let _ = write_down query response in
      loop t
  in
  let _ = loop queries in
  Mpd.Connection.close connection
