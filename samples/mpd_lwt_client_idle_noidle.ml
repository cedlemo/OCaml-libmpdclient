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

(* Simple client that connects to a mpd server with the "idle" command and get
 * one event of the mpd server. *)

let host = "127.0.0.1"
let port = 6600

let main_thread =
  Lwt.catch
    (fun () ->
      Mpd.Connection_lwt.initialize host port >>= fun connection ->
      Mpd.Client_lwt.initialize connection >>= fun client ->
      let%lwt banner = Mpd.Client_lwt.mpd_banner client in
      Lwt_io.write_line Lwt_io.stdout banner >>= fun () ->
      let thread1 =
        Lwt_io.write_line Lwt_io.stdout "Thread one: idle" >>= fun () ->
        Mpd.Client_lwt.idle client >>= function
        | Error message -> Lwt_io.write_line Lwt_io.stdout message
        | Ok event_name -> Lwt_io.write_line Lwt_io.stdout event_name
      in
      let _ =
        Lwt.on_cancel thread1 (fun () ->
            Lwt_io.write_line Lwt_io.stdout "Thread one: canceled"
            |> Lwt.ignore_result)
      in
      let thread2 =
        Lwt_io.write_line Lwt_io.stdout "Thread two: Wait" >>= fun () ->
        Lwt_unix.sleep 5.0 >>= fun () ->
        Lwt_io.write_line Lwt_io.stdout "Thread two: cancel thread one"
        >>= fun () ->
        Lwt.cancel thread1;
        Lwt.return_unit >>= fun () ->
        Lwt_io.write_line Lwt_io.stdout "Thread two: send noidle" >>= fun () ->
        Mpd.Client_lwt.noidle client >>= fun _ ->
        Lwt_io.write_line Lwt_io.stdout "Thread two: noidle sent"
      in
      Lwt.join [ thread1; thread2 ] >>= fun () -> Mpd.Client_lwt.close client)
    (function
      | Mpd.Connection_lwt.Lwt_unix_exn message ->
          Lwt_io.write_line Lwt_io.stderr message
      | _ -> Lwt_io.write_line Lwt_io.stderr "Uncaught exception. Exiting ...")

let () = Lwt_main.run main_thread
