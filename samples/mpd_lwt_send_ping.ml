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
    Connection_lwt.recvbytes connection
    >>= fun buf ->
      lwt_print_line (Printf.sprintf "received : %s" (Bytes.to_string buf))
      >>= fun _ ->
        Connection_lwt.write connection "ping\n"
        >>= fun _ ->
          Connection_lwt.recvbytes connection
          >>= fun buf ->
            lwt_print_line (Printf.sprintf "received : %s" (Bytes.to_string buf))
            >>= fun () ->
              Connection_lwt.close connection

let () =
  Lwt_main.run main_thread
