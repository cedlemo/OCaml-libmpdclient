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

(** Provides functions and type in order to communicate to the mpd server
 with commands and requests in Lwt threads. *)

open Lwt
open LwtConnection
open Status
open Protocol

type c

(** Initialize the client with a connection. *)
val initialize:
  LwtConnection.c -> c Lwt.t

(** Close the client *)
val close:
  c -> unit Lwt.t

(** Return the mpd banner that the server send at the first connection of the
    client. *)
val mpd_banner:
  c -> string

(** Loop on mpd event with the "idle" command
    the on_event function take the event response as argument and return
    true to stop or false to continue the loop *)
val idle:
  c -> (string -> bool Lwt.t) -> unit Lwt.t

(** Send to the mpd server a command. The response of the server is returned
    under the form of a Protocol.response type. *)
val send:
  c -> string -> Protocol.response option Lwt.t

(** Create a status request and returns the status under a Mpd.Status.s Lwt.t
    type.*)
val status:
  c -> Status.t option Lwt.t

(** Does nothing but return "OK". *)
val ping:
  c -> Protocol.response option Lwt.t

(** This is used for authentication with the server. PASSWORD is simply the
    plaintext password. *)
val password:
  c -> string -> Protocol.response option Lwt.t
