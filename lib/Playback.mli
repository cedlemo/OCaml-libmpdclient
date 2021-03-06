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

(** Controlling playback functions.
  https://www.musicpd.org/doc/protocol/playback_commands.html *)

val next: Client.t -> Protocol.response
(** Play next song in the playlist. *)

val previous: Client.t -> Protocol.response
(** Play previous song in the playlist. *)

val stop: Client.t -> Protocol.response
(** Stop playing.*)

val pause: Client.t -> bool -> Protocol.response
(** Toggle pause/resumers playing *)

val play: Client.t -> int -> Protocol.response
(** Begin playing the playlist at song number. *)

val playid: Client.t -> int -> Protocol.response
(** Begin playing the playlist at song id. *)

val seek: Client.t -> int -> float -> Protocol.response
(** Seek to the position time of entry songpos in the playlist. *)

val seekid: Client.t -> int -> float -> Protocol.response
(** Seek to the position time of song id. *)

val seekcur: Client.t -> float -> Protocol.response
(** Seek to the position time within the current song.
 TODO : If prefixed by '+' or '-', then the time is relative to the current
 playing position
 *)
