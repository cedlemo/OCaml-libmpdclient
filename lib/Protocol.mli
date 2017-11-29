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

(** Define the Mpd response and error types *)
(* https://github.com/sol/mpd/blob/master/src/ack.h *)

(** Type of error that could occur when a command is sent to the mpd server. *)
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

  (** Type of the response of the mpd server. *)
type response = Ok of string option | Error of (ack_error * int * string * string)

(** Get the error name of the error type. *)
val error_name:
  ack_error -> string

(** Returns the related type for the error returned by the server as a string. *)
val str_error_to_val:
  string -> ack_error

(** Parse the error response of the mpd server into the error type. *)
val parse_error_response:
  string -> (ack_error * int * string * string)

(** Parse the mpd server response *)
val parse_response:
  string -> response
