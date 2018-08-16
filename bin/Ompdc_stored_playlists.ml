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

open Cmdliner
open Ompdc_common

let listplaylists common_opts =
  let {host; port} = common_opts in
  let client = initialize_client {host; port} in
  let () = match Mpd.Stored_playlists.listplaylists client with
    | Error message -> print_endline message
    | Ok playlists -> List.iter print_endline playlists
  in
  Mpd.Client.close client

let listplaylists_t =
    let doc = "List all the playlists"
    in
    let man = [
               `S Manpage.s_description;
               `P doc;
               `Blocks help_section; ]
    in
    Term.(const listplaylists $ common_opts_t),
    Term.info "listplaylists" ~doc ~sdocs ~exits ~man

let cmds = [listplaylists_t]


