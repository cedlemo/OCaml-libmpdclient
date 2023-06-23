(*
 * Copyright 2017-2018 Cedric LE MOIGNE, cedlemo@gmx.com
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

type t = { connection : Connection.t; mpd_banner : string }

let initialize connection =
  let message = Connection.read_mpd_banner connection in
  let pattern = "OK \\(.*\\)\n" in
  let mpd_banner =
    match Str.string_match (Str.regexp pattern) message 0 with
    | true -> Str.matched_group 1 message
    | false -> message
  in
  { connection; mpd_banner }

let send_command client mpd_cmd =
  let { connection = c; _ } = client in
  let cmd = Utils.remove_new_lines mpd_cmd ^ "\n" in
  Connection.write c cmd;
  let response = Connection.read_command_response c in
  let () = Utils.print_data response in
  Protocol.parse_response response

let send_request client mpd_cmd =
  let { connection = c; _ } = client in
  let request = Utils.remove_new_lines mpd_cmd ^ "\n" in
  Connection.write c request;
  let response = Connection.read_request_response c in
  let () = Utils.print_data response in
  Protocol.parse_response response

let mpd_banner { mpd_banner = banner; _ } = banner

let status client =
  let response = send_request client "status" in
  match response with
  | Ok lines -> (
      match lines with
      | None -> Error "Empty status"
      | Some lines' ->
          let status_pairs = Utils.split_lines lines' in
          Ok (Status.parse status_pairs))
  | Error (ack, _ack_cmd_num, _cmd, ack_message) ->
      let message =
        String.concat " "
          [
            "Error type:";
            Protocol.error_name ack;
            "-- error message:";
            ack_message;
          ]
      in
      Error message

let ping client = send_command client "ping"

let password client mdp =
  send_command client (String.concat " " [ "password"; mdp ])

let tagtypes client =
  let response = send_request client "tagtypes" in
  match response with
  | Ok lines -> (
      match lines with
      | None -> []
      | Some lines' ->
          let tagid_keys_vals = Utils.split_lines lines' in
          List.rev (Utils.values_of_pairs tagid_keys_vals))
  | Error (_ack, _ack_cmd_num, _cmd, _error) -> []
(*
(** Remove one or more tags from the list of tag types the client is
 * interested in. These will be omitted from responses to this client. *)
let tagtypes_disable client tagtypes =
  send client (String.concat "" ["tagtypes disable ";
                                  String.concat " " tagtypes])
(** Re-enable one or more tags from the list of tag types for this client.
 * These will no longer be hidden from responses to this client. *)
let tagtypes_enable client tagtypes =
  send client (String.concat "" ["tagtypes enable ";
                                 String.concat " " tagtypes])

(** Clear the list of tag types this client is interested in. This means that
 * MPD will not send any tags to this client. *)
let tagtypes_clear client =
  send client "tagtypes clear"

(** Announce that this client is interested in all tag types. This is the
 * default setting for new clients. *)
let tagtypes_all client =
  send client "tagtypes all"
 *)

let close client =
  let { connection = c; _ } = client in
  Connection.write c "close\n";
  Connection.close c
