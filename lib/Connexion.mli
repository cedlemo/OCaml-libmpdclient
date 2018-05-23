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

(** Offer functions and type in order to handle connexions to the mpd server at
    the socket level. *)

type t
(** connexion type *)

val initialize: string -> int -> t
(** Create the connexion, exit if the connexion can not be initialized. *)

val hostname: t -> string
(** Retrieve the host's string of the initialized connexion. *)

val port: t -> int
(** Retrieve the port of the connexion of the initialized connexion. *)

val close: t -> unit
(** Close the connexion *)

val write: t -> string -> unit
(** Write to an Mpd connexion *)

val read: t -> string
(** Read in an Mpd connexion *)
