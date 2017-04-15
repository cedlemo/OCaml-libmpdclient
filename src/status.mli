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

(** Mpd_status is included in Mpd.Status. *)

type s
(** Current state of the mpd server. *)
type state
(** Default empty/null state *)
val empty : s
(** Parse list of strings into a Mpd Status type *)
val parse: string list -> s
(** Get the volume level from a Mpd Status *)
val volume: s -> int
(** Find out if the player is in repeat mode *)
val repeat: s -> bool
(** Find out if the player is in random mode *)
val random: s -> bool
(** Find out if the player is in single mode *)
val single: s -> bool
(** Find out if the player is in consume mode *)
val consume: s -> bool
(** Get the current playlist id *)
val playlist: s -> int
(** Get the current playlist length *)
val playlistlength: s -> int
(** Get the state of the player : Play / Pause / Stop *)
val state: s -> state
(** Get the song number of the current song stopped on or playing *)
val song: s -> int
(** Get the song id of the current song stopped on or playing *)
val songid: s -> int
(** Get the next song number based on the current song stopped on or playing *)
val nextsong: s -> int
(** Get the next song id based on the current song stopped on or playing *)
val nextsongid: s -> int
(** Get the total time elapsed (of current playing/paused song) *)
val time: s -> string
(** Get the total time elapsed within the current song, but with higher resolution *)
val elapsed: s -> float
(** Returns the totatl duration of the current song in seconds *)
val duration: s -> float
(** Get the instantaneous bitrate in kbps *)
val bitrate: s -> int
(** Get the crossfade in seconds of the current song *)
val xfade: s -> int
(** Get the mixramp threshold in dB *)
val mixrampdb: s -> float
(** Get the mixrampdelay in seconds *)
val mixrampdelay: s -> int
(** Get information of the audio file of the current song (sampleRate:bits:channels) *)
val audio: s -> string
(** Get the job id *)
val updating_db: s -> int
(** Get the error message if there is one *)
val error: s -> string
(** Build a status error message. When the status request return an error, this
 * function is useful to generate an empty status with the error message set. *)
val generate_error: string -> s
