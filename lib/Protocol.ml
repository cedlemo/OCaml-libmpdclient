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

type ack_error =
  | Not_list (* 1 *)
  | Arg (* 2 *)
  | Password (* 3 *)
  | Permission (* 4 *)
  | Unknown (* 5 *)
  | No_exist (* 50 *)
  | Playlist_max (* 51 *)
  | System (* 52 *)
  | Playlist_load (* 53 *)
  | Update_already (* 54 *)
  | Player_sync (* 55 *)
  | Exist (* 56 *)

type response =
  | Ok of string option
  | Error of (ack_error * int * string * string)

let error_name = function
  | Not_list -> "Not_list"
  | Arg -> "Arg"
  | Password -> "Password"
  | Permission -> "Permission"
  | Unknown -> "Unknown"
  | No_exist -> "No_exist"
  | Playlist_max -> "Playlist_max"
  | System -> "System"
  | Playlist_load -> "Playlist_load"
  | Update_already -> "Update_already"
  | Player_sync -> "Player_sync"
  | Exist -> "Exist"

let str_error_to_val str =
  match str with
  | "1" -> Not_list
  | "2" -> Arg
  | "3" -> Password
  | "4" -> Permission
  | "5" -> Unknown
  | "50" -> No_exist
  | "51" -> Playlist_max
  | "52" -> System
  | "53" -> Playlist_load
  | "54" -> Update_already
  | "55" -> Player_sync
  | "56" -> Exist
  | _ -> Unknown

let ok_response_pattern = "\\(\\(\n\\|.\\)*\\)OK$"
let ok_response_reg = Str.regexp ok_response_pattern

let error_response_pattern =
  let dec = "[0-9]" in
  let error = String.concat "" [ "\\("; dec; dec; "?\\)" ] in
  let cmd_num = String.concat "" [ "\\("; dec; "+\\)" ] in
  let cmd = "\\(.*\\)" in
  let message = "\\(.*\\)" in
  String.concat ""
    [ "ACK \\["; error; "\\@"; cmd_num; "\\] \\{"; cmd; "\\} "; message; "\n" ]

let error_response_reg = Str.regexp error_response_pattern

let is_ok_response mpd_response =
  Str.string_match ok_response_reg mpd_response 0

let is_error_response mpd_response =
  Str.string_match error_response_reg mpd_response 0

let parse_error_response mpd_response =
  ignore (Str.string_match error_response_reg mpd_response 0);
  let ack_val = str_error_to_val (Str.matched_group 1 mpd_response) in
  let ack_cmd_num = int_of_string (Str.matched_group 2 mpd_response) in
  let ack_cmd = Str.matched_group 3 mpd_response in
  let ack_message = Str.matched_group 4 mpd_response in
  (ack_val, ack_cmd_num, ack_cmd, ack_message)

let parse_response mpd_response =
  if is_ok_response mpd_response then
    let str = Str.matched_group 1 mpd_response in
    if str = "" then Ok None else Ok (Some str)
  else Error (parse_error_response mpd_response)

(** Type and functions used to check if the current response is full based on
    pattern defined by the mpd protocol.*)
type mpd_response = Incomplete | Complete of (string * int)

let check_full_response mpd_data pattern group useless_char =
  let response = Str.regexp pattern in
  match Str.string_match response mpd_data 0 with
  | true -> Complete (Str.matched_group group mpd_data, useless_char)
  | false -> (
      match is_error_response mpd_data with
      | true -> Complete (Str.matched_group 0 mpd_data, 0)
      | false -> Incomplete)

let full_mpd_banner mpd_data =
  let pattern = "OK \\(.*\\)\n" in
  check_full_response mpd_data pattern 1 4

let request_response mpd_data =
  let pattern = "\\(\\(\n\\|.\\)*OK\n\\)" in
  check_full_response mpd_data pattern 1 0

let command_response mpd_data =
  let pattern = "^\\(OK\n\\)\\(\n\\|.\\)*" in
  check_full_response mpd_data pattern 1 0

let full_mpd_idle_event mpd_data =
  let pattern = "changed: \\(\\(\n\\|.\\)*\\)OK\n" in
  match check_full_response mpd_data pattern 1 12 with
  (* Check if there is an empty response that follow an noidle command *)
  | Incomplete -> command_response mpd_data
  | Complete response -> Complete response
