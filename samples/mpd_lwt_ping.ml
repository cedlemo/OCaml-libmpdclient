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

let lwt_print_line str =
  Lwt_io.write_line Lwt_io.stdout str

let main_thread =
  let open Mpd in
  Connection_lwt.initialize host port
  >>= fun connection ->
    Client_lwt.initialize connection
    >>= fun client ->
      Client_lwt.ping client
      >>= function
        | Error (_, _, _, message) -> lwt_print_line (Printf.sprintf "No response : %s" message)
        | Ok response ->
            lwt_print_line begin
              match response with
              | None -> "Ok"
              | Some s -> s
            end

let () =
  Lwt_main.run main_thread
