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
open Lwt.Infix
open Notty
open Notty_lwt
open Ompdc_common

module Terminal = Notty_lwt.Term

let render (w, h) client =
  Mpd.Client_lwt.status client
  >>= fun response ->
    match response with
    | Error message -> Lwt.return I.(strf ~attr:A.(fg red) "[there is a pb %s]" message)
    | Ok status -> let state = Mpd.Status.state status in
       Lwt.return I.(strf ~attr:A.(fg white) "[state %s]" (Mpd.Status.string_of_state state))

let listen_mpd_event client =
  Mpd.Client_lwt.idle client >|= fun evt -> `Mpd_event evt

let event term = Lwt_stream.get (Terminal.events term) >|= function
  | Some (`Resize _ | #Unescape.event as x) -> x
  | None -> `End

let rec loop term (e, t) dim client =
  (e <?> t) >>= function
  | `End | `Key (`Escape, []) ->
      Lwt.return_unit
  | `Mpd_event event_name ->
      render dim client
      >>= fun img ->
        Terminal.image term img
        >>= fun () ->
            loop term (e, listen_mpd_event client) dim client
  | `Resize dim ->
      render dim client
      >>= fun img ->
        Terminal.image term img
        >>= fun () ->
        loop term (event term, t) dim client
  | _ -> loop term (event term, t) dim client

let interface client =
  let term = Terminal.create () in
  let size = Terminal.size term in
  render size client
  >>= fun img ->
    Terminal.image term img
    >>= fun () ->
    loop term (event term, listen_mpd_event client) size client

let idle common_opts =
  let open Mpd in
  let {host; port} = common_opts in
  let main_thread =
    Mpd.Connection_lwt.initialize host port
    >>= fun connection ->
      Mpd.Client_lwt.initialize connection
      >>= fun client ->
        interface client
  in
  Lwt_main.run (
    Lwt.catch
      (fun () -> main_thread)
      (function
        | Mpd.Connection_lwt.Lwt_unix_exn message ->
            Lwt_io.write_line Lwt_io.stderr message
        | _ -> Lwt_io.write_line Lwt_io.stderr "Exception not handled. Exit ..."
      )
  )

open Cmdliner
let cmd =
  let doc = "Use Ompdc an Mpd server events listener. Quit with Ctl+Alt+C." in
  let man = [ `S Manpage.s_description;
              `P "Idle command that display events of the Mpd server.";
              `Blocks help_section
  ] in
  Term.(const idle $ common_opts_t),
  Term.info "idle" ~doc ~sdocs ~exits ~man
