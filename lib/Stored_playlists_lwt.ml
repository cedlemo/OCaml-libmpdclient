(*
 * Copyright 2017-2018 Cedric LE MOIGNE, cedlemo@gmx.com
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

open Lwt.Infix

let listplaylists client =
  Client_lwt.request client "listplaylists"
  >>= function
  | Protocol.Error (_, _ ,_ , message) -> Lwt.return_error message
  | Protocol.Ok (response_opt) -> match response_opt with
    | None -> Lwt.return_ok []
        | Some response -> let playlists = Utils.read_list_playlists response in
          Lwt.return_ok playlists

let load client playlist ?range () =
  let request = match range with
    | None -> "load " ^ playlist
    | Some (s, e) -> let r = String.concat ":" [string_of_int s; string_of_int e] in
      String.concat " " ["load"; playlist; r]
  in
  Client_lwt.request client request

let playlistadd client playlist uri =
  let request = String.concat " " ["playlistadd"; playlist; uri] in
  Client_lwt.send client request

let playlistclear client playlist =
  let request = "playlistclear " ^ playlist in
  Client_lwt.send client request

let playlistdelete client playlist position =
  let request = String.concat " " ["playlistclear";
                                   playlist;
                                   string_of_int position] in
  Client_lwt.send client request

let playlistmove client playlist from to_dest =
  let request = String.concat " " ["playlistmove";
                                   playlist;
                                   string_of_int from;
                                   string_of_int to_dest] in
  Client_lwt.send client request

let rename client playlist new_name =
  let request = String.concat " " ["rename";
                                   playlist;
                                   new_name] in
  Client_lwt.send client request

let rm client playlist =
  let request = "rm " ^ playlist in
  Client_lwt.send client request

let save client playlist =
  let request = "save " ^ playlist in
  Client_lwt.send client request
