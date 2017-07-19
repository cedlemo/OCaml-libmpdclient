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

(** Plays next song in the playlist. *)
val next:
  LwtClient.c -> Protocol.response Lwt.t

(** Plays previous song in the playlist. *)
val prev:
  LwtClient.c -> Protocol.response Lwt.t

(** Stops playing.*)
val stop:
  LwtClient.c -> Protocol.response Lwt.t

(** Toggles pause/resumers playing *)
val pause:
  LwtClient.c -> bool -> Protocol.response Lwt.t

(** Begins playing the playlist at song number. *)
val play:
  LwtClient.c -> int -> Protocol.response Lwt.t

(** Begins playing the playlist at song id. *)
val playid:
  LwtClient.c -> int -> Protocol.response Lwt.t

(** Seeks to the position time of entry songpos in the playlist. *)
val seek:
  LwtClient.c -> int -> float -> Protocol.response Lwt.t

(** Seeks to the position time of song id. *)
val seekid:
  LwtClient.c -> int -> float -> Protocol.response Lwt.t

(** Seeks to the position time within the current song.
 TODO : If prefixed by '+' or '-', then the time is relative to the current
 playing position
 *)
val seekcur:
  LwtClient.c -> float -> Protocol.response Lwt.t
