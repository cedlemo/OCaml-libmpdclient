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

(** Provides functions and type in order to communicate to the mpd server
 with commands and requests in Lwt threads. *)

type t
(** Type for a Mpd Client to be used with Lwt promises. *)

val initialize: Connection_lwt.t -> t Lwt.t
(** Initialize the client with a connection. *)

val close: t -> unit Lwt.t
(** Close the client *)

val mpd_banner: t -> string Lwt.t
(** Return the mpd banner that the server send at the first connection of the
    client. *)

val idle: t -> (string, string) Pervasives.result Lwt.t
(** Wait for an event to occur in order to return. When a Client send this
 *  command to the Mpd server throught its connection, the Mpd server do
 *  not answer to any other command except the noidle command. The idea is
 *  to first cancel the promise that has send the "idle" command with
 *  Lwt.cancel and then send the noidle command to the Mpd server. An
 *  example can be found in samples/mpd_lwt_client_idle_noidle.ml. *)

val idle_loop: t -> (string -> bool Lwt.t) -> unit Lwt.t
(** Loop on mpd event with the "idle" command
    the on_event function take the event response as argument and return
    true to stop or false to continue the loop *)

val send: t -> string -> Protocol.response Lwt.t
(** Send to the mpd server a command. The response of the server is returned
    under the form of a Protocol.response type. *)

val request:
  t -> string -> Protocol.response Lwt.t
(** Send to the mpd server a request. The response of the server is returned
    under the form of a Protocol.response type. A request is different from
    a command because a command generate an action from Mpd and returns "OK" or
    an error while a request does not generate an action from Mpd and returns
    "some data to analyse"OK or an error.*)

val status: t -> (Status.t, string) Pervasives.result Lwt.t
(** Create a status request and returns the status under a Mpd.Status.s Lwt.t
    type.*)

val ping: t -> Protocol.response Lwt.t
(** Does nothing but return "OK". *)

val password: t -> string -> Protocol.response Lwt.t
(** This is used for authentication with the server. PASSWORD is simply the
    plaintext password. *)

val noidle:
  t -> Protocol.response Lwt.t
(** This command is needed to stop listening after a Client.idle command.
    An example of usage can be seen in samples/mpd_lwt_client_idle_noidle.exe. *)
