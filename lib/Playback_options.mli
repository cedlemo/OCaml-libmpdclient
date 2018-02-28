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

(** functions that configure all the playbackoptions *)

val consume: Client.t -> bool -> Protocol.response
(** Sets consume state to STATE, STATE should be false or true.
    When consume is activated, each song played is removed from playlist. *)

val crossfade: Client.t -> int -> Protocol.response
(** Sets crossfading between songs. *)

val mixrampdb: Client.t -> int -> Protocol.response
(** Sets the threshold at which songs will be overlapped.
    Like crossfading but doesn't fade the track volume, just overlaps. The
    songs need to have MixRamp tags added by an external tool. 0dB is the
    normalized maximum volume so use negative values, I prefer -17dB.
    In the absence of mixramp tags crossfading will be used.
    See http://sourceforge.net/projects/mixramp *)

type mixrampd_t = Nan | Seconds of float
(** Type for the command mixrampdelay, it can be float number for seconds or nan. *)

val mixrampdelay: Client.t -> mixrampd_t -> Protocol.response
(** Additional time subtracted from the overlap calculated by mixrampdb. A
    value of "nan" disables MixRamp overlapping and falls back to crossfading. *)

val random: Client.t -> bool -> Protocol.response
(** Sets random state to STATE, STATE should be true or false *)

val repeat: Client.t -> bool -> Protocol.response
(** Sets repeat state to STATE, STATE should be false or true. *)

val setvol: Client.t -> int -> Protocol.response
(** Sets volume to VOL, the range of volume is 0-100. *)

val single: Client.t -> bool -> Protocol.response
(** Sets single state to STATE, STATE should be 0 or 1. When single is
    activated, playback is stopped after current song, or song is repeated if
    the 'repeat' mode is enabled. *)

type gain_mode_t =
  | Off
  | Track
  | Album
  | Auto
(** gain_mode type for the command replay_gain_mode. *)

val replay_gain_mode: Client.t -> gain_mode_t -> Protocol.response
(** Sets the replay gain mode. One of off, track, album, auto.
    Changing the mode during playback may take several seconds, because the
    new settings does not affect the buffered data.
    This command triggers the options idle event. *)

