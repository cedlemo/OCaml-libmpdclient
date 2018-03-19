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

type ack_error =
  | Not_list        (* 1 *)
  | Arg             (* 2 *)
  | Password        (* 3 *)
  | Permission      (* 4 *)
  | Unknown         (* 5 *)
  | No_exist        (* 50 *)
  | Playlist_max    (* 51 *)
  | System          (* 52 *)
  | Playlist_load   (* 53 *)
  | Update_already  (* 54 *)
  | Player_sync     (* 55 *)
  | Exist           (* 56 *)

type response = Ok of string option | Error of (ack_error * int * string * string)

let error_name = function
  | Not_list      -> "Not_list"
  | Arg           -> "Arg"
  | Password      -> "Password"
  | Permission    -> "Permission"
  | Unknown       -> "Unknown"
  | No_exist      -> "No_exist"
  | Playlist_max  -> "Playlist_max"
  | System        -> "System"
  | Playlist_load -> "Playlist_load"
  | Update_already-> "Update_already"
  | Player_sync   -> "Player_sync"
  | Exist         -> "Exist"

let str_error_to_val str =
  match str with
  | "1"  -> Not_list
  | "2"  -> Arg
  | "3"  -> Password
  | "4"  -> Permission
  | "5"  -> Unknown
  | "50" -> No_exist
  | "51" -> Playlist_max
  | "52" -> System
  | "53" -> Playlist_load
  | "54" -> Update_already
  | "55" -> Player_sync
  | "56" -> Exist
  | _ -> Unknown

let parse_error_response mpd_response =
  let dec = "[0-9]" in
  let error = "\\(" ^ dec ^ dec ^ "?\\)" in
  let cmd_num = "\\(" ^ dec ^ "+\\)" in
  let cmd = "\\(.*\\)" in
  let message = "\\(.*\\)" in
  let pattern = "ACK \\[" ^ error ^ "\\@" ^ cmd_num ^ "\\] \\{" ^
                cmd ^ "\\} " ^ message ^ "\n" in
  let reg = Str.regexp pattern in
  ignore(Str.string_match reg mpd_response 0);
  let ack_val = str_error_to_val (Str.matched_group 1 mpd_response) in
  let ack_cmd_num = int_of_string(Str.matched_group 2 mpd_response) in
  let ack_cmd = Str.matched_group 3 mpd_response in
  let ack_message = Str.matched_group 4 mpd_response in
  (ack_val, ack_cmd_num, ack_cmd, ack_message)

let parse_response mpd_response =
  let ok_response_reg = Str.regexp "\\(\\(\n\\|.\\)*\\)OK$" in
  if (Str.string_match ok_response_reg mpd_response 0 == true) then
    let str = Str.matched_group 1 mpd_response in
    if str = "" then Ok (None) else Ok (Some str)
  else
    Error (parse_error_response mpd_response)
