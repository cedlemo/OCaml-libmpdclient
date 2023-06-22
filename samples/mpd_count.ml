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

let host = "127.0.0.1"
let port = 6600

open Mpd.Music_database

let () =
  let connection = Mpd.Connection.initialize host port in
  let client = Mpd.Client.initialize connection in
  match Mpd.Music_database.count client [] ~group:Mpd.Tags.Artist () with
  | Error message -> print_endline message
  | Ok count ->
      List.iter (fun {songs; playtime; misc} ->
              Printf.printf "%d %f %s" songs playtime misc) count

