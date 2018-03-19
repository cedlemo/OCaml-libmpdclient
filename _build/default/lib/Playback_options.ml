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

let consume client state =
  match state with
  | true  -> Client.send client "consume 1"
  | false -> Client.send client "consume 0"

let crossfade client seconds =
  Client.send client (String.concat " " ["crossfade";
                                             string_of_int seconds])

let mixrampdb client seconds =
  Client.send client (String.concat " " ["mixrampdb";
                                             string_of_int seconds])

type mixrampd_t =
  | Nan
  | Seconds of float

let mixrampdelay client delay =
  match delay with
  | Nan -> Client.send client "mixrampdelay nan"
  | Seconds (s) -> Client.send client (String.concat " " ["mixrampdelay";
                                                           string_of_float s])
let random client state =
  match state with
  | true  -> Client.send client "random 1"
  | false -> Client.send client "random 0"

let repeat client state =
  match state with
  | true  -> Client.send client "repeat 1"
  | false -> Client.send client "repeat 0"

let setvol client volume =
  Client.send client (String.concat " " ["setvol";
                                             string_of_int volume])

let single client state =
  match state with
  | true  -> Client.send client "single 1"
  | false -> Client.send client "single 0"

type gain_mode_t =
  | Off
  | Track
  | Album
  | Auto

let replay_gain_mode client mode =
  match mode with
  | Off -> Client.send client "replay_gain_mode off"
  | Track -> Client.send client "replay_gain_mode track"
  | Album -> Client.send client "replay_gain_mode album"
  | Auto -> Client.send client "replay_gain_mode auto"

