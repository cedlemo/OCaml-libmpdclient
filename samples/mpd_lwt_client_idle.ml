(*
 * Copyright 2017 Cedric LE MOIGNE, cedlemo@gmx.com
 * This file is part of OCaml-libmpdclient.
 *
 * OCaml-libmpdclient is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * h:noh::j
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

open Lwt
open Mpd

(* Simple client that connects to a mpd server with the "idle" command and get
 * one event of the mpd server. *)

let host = "127.0.0.1"
let port = 6600

let on_mpd_event = function
  | "mixer" -> print_endline "Mixer related command has been executed"; Lwt.return true
  | _ as event_name -> print_endline (("-" ^ event_name) ^ "-"); Lwt.return false

let main_thread =
   Lwt.catch
   (fun () ->
     Mpd.Connection_lwt.initialize host port
     >>= fun connection ->
       Mpd.Client_lwt.initialize connection
       >>= fun client ->
         Lwt_io.write_line Lwt_io.stdout (Mpd.Client_lwt.mpd_banner client)
         >>= fun () ->
           Mpd.Client_lwt.idle client
           >>= function
             | Error message -> Mpd.Client_lwt.close client
                                >>= fun () ->
                                  Lwt_io.write_line Lwt_io.stdout message >|= fun () -> 125
             | Ok event_name -> Lwt_io.write_line Lwt_io.stdout event_name
                                    >>= fun () ->
                                      Mpd.Client_lwt.close client >|= fun () -> 0
   )
   (function
     | Mpd.Connection_lwt.Lwt_unix_exn message ->
         Lwt_io.write_line Lwt_io.stderr message
         >>= fun () ->
           Lwt.return 125
     | _ ->
         Lwt_io.write_line Lwt_io.stderr "Uncaught exception. Exiting ..."
         >>= fun () ->
           Lwt.return 125
   )
let () = exit (Lwt_main.run main_thread)
