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

type t = {connection : LwtConnection.t; mpd_banner : string }

let initialize connection =
  LwtConnection.read_mpd_banner connection
  >>= fun message ->
  Lwt.return {connection = connection; mpd_banner = message}

let close client =
let {connection = connection; _} = client in
LwtConnection.close connection

let mpd_banner {mpd_banner = banner; _ } =
  banner

let rec idle client on_event =
  let {connection = connection; _} = client in
  let cmd = "idle\n" in
  LwtConnection.write connection cmd
  >>= function
  | (-1) -> Lwt.return () (* TODO: Should return a meaningfull value so that the user can exit on this value. *)
  | _ -> LwtConnection.read_idle_events connection
      >>= fun response ->
        on_event response
        >>=fun stop ->
          match stop with
          | true -> Lwt.return ()
          | false -> idle client on_event

let send client cmd =
  let {connection = c; _} = client in
  LwtConnection.write c (cmd ^ "\n")
  >>= function
    | (-1) -> Lwt.return_none (* TODO: Should return a meaningfull value so that the user can exit on this value. *)
    | _ -> LwtConnection.read_command_response c
      >>= fun response ->
      let parsed_response = Some (Protocol.parse_response response) in
      Lwt.return parsed_response

let status client =
  send client "status"
  >>= function
    | None -> Lwt.return_none
    | Some response -> Lwt.return response
                       >>= function
                         | Ok (lines) -> let status_pairs = Utils.split_lines lines in
                             let status = Some (Status.parse status_pairs) in Lwt.return status
                         | Error (ack, ack_cmd_num, cmd, error) -> let status = Some (Status.generate_error error) in
                             Lwt.return status

let ping client =
  send client "ping"

let password client mdp =
  send client (String.concat " " ["password"; mdp])
