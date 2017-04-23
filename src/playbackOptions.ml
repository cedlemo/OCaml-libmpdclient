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
  | true  -> Mpd.Client.send client "consume 1"
  | false -> Mpd.Client.send client "consume 0"

let crossfade client seconds =
  Mpd.Client.send client (String.concat " " ["crossfade";
                                             string_of_int seconds])

let mixrampdb client seconds =
  Mpd.Client.send client (String.concat " " ["mixrampdb";
                                             string_of_int seconds])

type mixrampd_t =
  | Nan
  | Seconds of int

let mixrampdelay client delay =
  match delay with
  | Nan -> Mpd.Client.send client "mixrampdelay nan"
  | Seconds (s) -> Mpd.Client.send client (String.concat " " ["mixrampdb";
                                                              string_of_int s])

