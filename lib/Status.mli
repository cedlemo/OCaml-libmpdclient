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

(** Status : get informations on the current status of the Mpd server. *)

type t
(** Main status type that contains all the status information of the server. *)

type state =
  | Play
  | Pause
  | Stop
  | ErrState
      (** Current state (playing, pause or stopped) of the mpd server. *)

val string_of_state : state -> string
(** Get the string representation of a state. *)

val parse : string list -> t
(** Parse list of strings into a Mpd Status type *)

val volume : t -> int
(** Get the volume level from a Mpd Status *)

val repeat : t -> bool
(** Find out if the player is in repeat mode *)

val random : t -> bool
(** Find out if the player is in random mode *)

val single : t -> bool
(** Find out if the player is in single mode *)

val consume : t -> bool
(** Find out if the player is in consume mode *)

val playlist : t -> int
(** Get the current playlist id *)

val playlistlength : t -> int
(** Get the current playlist length *)

val state : t -> state
(** Get the state of the player : Play / Pause / Stop *)

val song : t -> int
(** Get the song number of the current song stopped on or playing *)

val songid : t -> int
(** Get the song id of the current song stopped on or playing *)

val nextsong : t -> int
(** Get the next song number based on the current song stopped on or playing *)

val nextsongid : t -> int
(** Get the next song id based on the current song stopped on or playing *)

val time : t -> string
(** Get the total time elapsed (of current playing/paused song) *)

val elapsed : t -> float
(** Get the total time elapsed within the current song, but with higher
    resolution *)

val duration : t -> float
(** Returns the totatl duration of the current song in seconds *)

val bitrate : t -> int
(** Get the instantaneous bitrate in kbps *)

val xfade : t -> int
(** Get the crossfade in seconds of the current song *)

val mixrampdb : t -> float
(** Get the mixramp threshold in dB *)

val mixrampdelay : t -> float
(** Get the mixrampdelay in seconds *)

val audio : t -> string
(** Get information of the audio file of the current song
    (sampleRate:bits:channels) *)

val updating_db : t -> int
(** Get the job id *)

val error : t -> string
(** Get the error message if there is one *)
