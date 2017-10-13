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

let consume client = function
  | true  -> LwtClient.send client "consume 1"
  | false -> LwtClient.send client "consume 0"

let crossfade client seconds =
  LwtClient.send client (String.concat " " ["crossfade";
                                             string_of_int seconds])

let mixrampdb client seconds =
  LwtClient.send client (String.concat " " ["mixrampdb";
                                             string_of_int seconds])

type mixrampd_t =
  | Nan
  | Seconds of int

let mixrampdelay client = function
  | Nan -> LwtClient.send client "mixrampdelay nan"
  | Seconds (s) -> LwtClient.send client (String.concat " " ["mixrampdb";
                                                              string_of_int s])
let random client = function
  | true  -> LwtClient.send client "random 1"
  | false -> LwtClient.send client "random 0"

let repeat client = function
  | true  -> LwtClient.send client "repeat 1"
  | false -> LwtClient.send client "repeat 0"

let setvol client volume =
  LwtClient.send client (String.concat " " ["setvol";
                                             string_of_int volume])

let single client = function
  | true  -> LwtClient.send client "single 1"
  | false -> LwtClient.send client "single 0"

type gain_mode_t =
  | Off
  | Track
  | Album
  | Auto

let replay_gain_mode client = function
  | Off -> LwtClient.send client "replay_gain_mode off"
  | Track -> LwtClient.send client "replay_gain_mode track"
  | Album -> LwtClient.send client "replay_gain_mode album"
  | Auto -> LwtClient.send client "replay_gain_mode auto"
