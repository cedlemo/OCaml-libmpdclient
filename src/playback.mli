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

(** Controlling playback functions.
  https://www.musicpd.org/doc/protocol/playback_commands.html *)

(** Plays next song in the playlist. *)
val next: Mpd.Client.c -> Protocol.response

(** Plays previous song in the playlist. *)
val prev: Mpd.Client.c -> Protocol.response

(** Stops playing.*)
val stop: Mpd.Client.c -> Protocol.response

(** Toggles pause/resumers playing *)
val pause: Mpd.Client.c -> bool -> Protocol.response

(** Begins playing the playlist at song number. *)
val play: Mpd.Client.c -> int -> Protocol.response

(** Begins playing the playlist at song id. *)
val playid: Mpd.Client.c -> int -> Protocol.response

(** Seeks to the position time of entry songpos in the playlist. *)
val seek: Mpd.Client.c -> int -> float -> Protocol.response

(** Seeks to the position time of song id. *)
val seekid: Mpd.Client.c -> int -> float -> Protocol.response

(** Seeks to the position time within the current song.
 TODO : If prefixed by '+' or '-', then the time is relative to the current
 playing position
 *)
val seekcur: Mpd.Client.c -> float -> Protocol.response
