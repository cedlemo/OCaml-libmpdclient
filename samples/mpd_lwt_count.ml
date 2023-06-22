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

open Lwt.Infix

let host = "127.0.0.1"
let port = 6600
let lwt_print_line str = Lwt_io.write_line Lwt_io.stdout str

open Mpd.Music_database_lwt

let main_thread =
  let open Mpd in
  Connection_lwt.initialize host port >>= fun connection ->
  Client_lwt.initialize connection >>= fun client ->
  Music_database_lwt.count client [] ~group:Tags.Artist () >>= function
  | Error message -> lwt_print_line message
  | Ok count ->
      lwt_print_line (string_of_int (List.length count)) >>= fun () ->
      Lwt_list.iter_s
        (fun { songs; playtime; misc } ->
          lwt_print_line (Printf.sprintf "%d %f %s" songs playtime misc))
        count
      >>= fun () -> Client_lwt.close client

let () = Lwt_main.run main_thread
