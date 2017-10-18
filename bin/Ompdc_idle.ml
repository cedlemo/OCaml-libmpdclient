(*
 * Copyright 2017 Cedric LE MOIGNE, cedlemo@gmx.com
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
open Lwt.Infix

let lwt_print_line str =
  Lwt_io.write_line Lwt_io.stdout str

let on_mpd_event event_name =
  match event_name with
  | "mixer" -> print_endline "Mixer related command has been executed"; Lwt.return true
  | _ -> print_endline (("-" ^ event_name) ^ "-"); Lwt.return false


let idle common_opts =
  let open Mpd in
  let {host; port} = common_opts in
  let main_thread =
    Mpd.LwtConnection.initialize host port
    >>= fun connection ->
      Lwt_io.write_line Lwt_io.stdout "Client on"
      >>= fun () ->
        Mpd.LwtClient.initialize connection
        >>= fun client ->
          Lwt_io.write_line Lwt_io.stdout (Mpd.LwtClient.mpd_banner client)
          >>= fun () ->
            Mpd.LwtClient.idle client on_mpd_event
  in
  Lwt_main.run (
    Lwt.catch
      (fun () -> main_thread)
      (function
        | Mpd.LwtConnection.Lwt_unix_exn message ->
            Lwt_io.write_line Lwt_io.stderr message
        | _ -> Lwt_io.write_line Lwt_io.stderr "Exception not handled. Exit ..."
      )
  )
let cmd =
  let doc = "Use Ompdc an Mpd server events listener. Quit with Ctl+Alt+C." in
  let man = [ `S Manpage.s_description;
              `P "Idle command that display events of the Mpd server.";
              `Blocks help_section
  ] in
  Term.(const idle $ common_opts_t),
  Term.info "idle" ~doc ~sdocs ~exits ~man
