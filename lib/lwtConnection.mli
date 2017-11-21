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

(** Offer functions and type in order to handle connections to the mpd server at
   the socket level in Lwt thread. *)

open Lwt

(** Lwt connection type for thread usage *)
type t

exception Lwt_unix_exn of string

(** Create the connection in a Lwt thread, throws an exception Mpd_Lwt_unix_exn
    of string when an error occurs. *)
val initialize:
  string -> int -> t Lwt.t

(** Write in a Mpd connection throught a Lwt thread. It fails
    with an exception Mpd_Lwt_unix_exn of string. *)
val write:
  t -> string -> int Lwt.t

val read_mpd_banner:
  t -> string Lwt.t

val read_idle_events:
  t -> string Lwt.t

val read_command_response:
  t -> string Lwt.t

val close:
  t -> unit Lwt.t
