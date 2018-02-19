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
 with commands and requests. *)

type t
(** Client type *)

val initialize: Connection.t -> t
(** Initialize the client with a connection. *)

val send: t -> string -> Protocol.response
(** Send to the mpd server a command or a request. The response of the server
    is returned under the form of a Protocol.response type. *)

val mpd_banner: t -> string
(** Return the mpd banner that the server send at the first connection of the
    client. *)

val status: t -> (Status.t, string) result
(** Create a status request and returns the status under a Mpd.Status.t
    type if no error occurs.*)

val ping: t -> Protocol.response
(** Does nothing but return "OK". *)

val password: t -> string -> Protocol.response
(** This is used for authentication with the server. PASSWORD is simply the
    plaintext password. *)

val close: t -> unit
(** Closes the connection to MPD. MPD will try to send the remaining output
    buffer before it actually closes the connection, but that cannot be
    guaranteed. This command will not generate a response. *)

val tagtypes: t -> string list
(** Shows a list of available tag types. It is an intersection of the
    metadata_to_use setting and this client's tag mask.
    About the tag mask: each client can decide to disable any number of tag
    types, which will be omitted from responses to this client. That is a good
    idea, because it makes responses smaller. The following tagtypes sub
    commands configure this list. *)

(**/**)
(* val tagtypes_disable: t -> string list -> Protocol.response
   val tagtypes_clear: t -> Protocol.response
   val tagtypes_all: t -> Protocol.response *)
(**/**)
