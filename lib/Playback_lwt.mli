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

(** Controlling playback functions in Lwt thread.
  https://www.musicpd.org/doc/protocol/playback_commands.html *)

val next:
  Client_lwt.t -> Protocol.response Lwt.t
(** Play next song in the playlist. *)

val previous:
  Client_lwt.t -> Protocol.response Lwt.t
(** Play previous song in the playlist. *)

val stop:
  Client_lwt.t -> Protocol.response Lwt.t
(** Stop playing.*)

val pause:
  Client_lwt.t -> bool -> Protocol.response Lwt.t
(** Toggle pause/resumers playing *)

val play:
  Client_lwt.t -> int -> Protocol.response Lwt.t
(** Begin playing the playlist at song number. *)

val playid:
  Client_lwt.t -> int -> Protocol.response Lwt.t
(** Begin playing the playlist at song id. *)

val seek:
  Client_lwt.t -> int -> float -> Protocol.response Lwt.t
(** Seek to the position time of entry songpos in the playlist. *)

val seekid:
  Client_lwt.t -> int -> float -> Protocol.response Lwt.t
(** Seek to the position time of song id. *)

val seekcur:
  Client_lwt.t -> float -> Protocol.response Lwt.t
(** Seek to the position time within the current song.
 TODO : If prefixed by '+' or '-', then the time is relative to the current
 playing position
 *)
