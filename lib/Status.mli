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

type t
(** Current state of the mpd server. *)
type state
(** Get the string representation of a state. *)
val string_of_state:
  state -> string
(** Default empty/null state *)
val empty : t
(** Parse list of strings into a Mpd Status type *)
val parse:
  string list -> t
(** Get the volume level from a Mpd Status *)
val volume:
  t -> int
(** Find out if the player is in repeat mode *)
val repeat:
  t -> bool
(** Find out if the player is in random mode *)
val random:
  t -> bool
(** Find out if the player is in single mode *)
val single:
  t -> bool
(** Find out if the player is in consume mode *)
val consume:
  t -> bool
(** Get the current playlist id *)
val playlist:
  t -> int
(** Get the current playlist length *)
val playlistlength:
  t -> int
(** Get the state of the player : Play / Pause / Stop *)
val state:
  t -> state
(** Get the song number of the current song stopped on or playing *)
val song:
  t -> int
(** Get the song id of the current song stopped on or playing *)
val songid:
  t -> int
(** Get the next song number based on the current song stopped on or playing *)
val nextsong:
  t -> int
(** Get the next song id based on the current song stopped on or playing *)
val nextsongid:
  t -> int
(** Get the total time elapsed (of current playing/paused song) *)
val time:
  t -> string
(** Get the total time elapsed within the current song, but with higher
    resolution *)
val elapsed:
  t -> float
(** Returns the totatl duration of the current song in seconds *)
val duration:
  t -> float
(** Get the instantaneous bitrate in kbps *)
val bitrate:
  t -> int
(** Get the crossfade in seconds of the current song *)
val xfade:
  t -> int
(** Get the mixramp threshold in dB *)
val mixrampdb:
  t -> float
(** Get the mixrampdelay in seconds *)
val mixrampdelay:
  t -> float
(** Get information of the audio file of the current song
    (sampleRate:bits:channels) *)
val audio:
  t -> string
(** Get the job id *)
val updating_db:
  t -> int
(** Get the error message if there is one *)
val error:
  t -> string
(** Build a status error message. When the status request return an error, this
    function is useful to generate an empty status with the error message field
    set.*)
val generate_error:
  string -> t
