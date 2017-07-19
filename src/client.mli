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
 with commands and requests. *)
open Connection
open Status
open Protocol

(** Client type *)
type c

  (** Initialize the client with a connection. *)
val initialize:
  Connection.c -> c

(** Send to the mpd server a command or a request. The response of the server
    is returned under the form of a Protocol.response type. *)
val send:
  c -> string -> Protocol.response

(** Return the mpd banner that the server send at the first connection of the
    client. *)
val mpd_banner:
  c -> string

(** Create a status request and returns the status under a Mpd.Status.s
    type.*)
val status:
  c -> Status.s

(** Does nothing but return "OK". *)
val ping:
  c -> Protocol.response

(** This is used for authentication with the server. PASSWORD is simply the
    plaintext password. *)
val password:
  c -> string -> Protocol.response

(** Closes the connection to MPD. MPD will try to send the remaining output
    buffer before it actually closes the connection, but that cannot be
    guaranteed. This command will not generate a response. *)
val close:
  c -> unit

(** Shows a list of available tag types. It is an intersection of the
    metadata_to_use setting and this client's tag mask.
    About the tag mask: each client can decide to disable any number of tag
    types, which will be omitted from responses to this client. That is a good
    idea, because it makes responses smaller. The following tagtypes sub
    commands configure this list. *)
val tagtypes:
  c -> string list

(* val tagtypes_disable: c -> string list -> Protocol.response
   val tagtypes_clear: c -> Protocol.response
   val tagtypes_all: c -> Protocol.response *)
