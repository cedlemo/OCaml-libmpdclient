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

(** Create the connection in a Lwt thread, returns None if the connection
    can not be initialized. *)
val initialize:
  string -> int -> t option Lwt.t

(** Write in a Mpd connection throught a Lwt thread. Return -1 if an it fails
    with an exception. *)
val write:
  t -> string -> int Lwt.t

val read_mpd_banner:
  t -> string option Lwt.t

val read_idle_events:
  t -> string option Lwt.t

val read_command_response:
  t -> string option Lwt.t

val close:
  t -> unit option Lwt.t
