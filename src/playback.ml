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

let next client =
  Mpd.Client.send client "next"

let prev client =
  Mpd.Client.send client "prev"

let stop client =
  Mpd.Client.send client "stop"

let pause client arg =
  match arg with
  | true -> Mpd.Client.send client "pause 1"
  | _    -> Mpd.Client.send client "pause 0"

let play client songpos =
  Mpd.Client.send client (String.concat " " ["play";
                                              string_of_int songpos])

let playid client songid =
  Mpd.Client.send client (String.concat " " ["playid";
                                              string_of_int songid])

let seek client songpos time =
  Mpd.Client.send client (String.concat " " ["seek";
                                              string_of_int songpos;
                                              string_of_float time])

let seekid client songid time =
  Mpd.Client.send client (String.concat " " ["seekid";
                                              string_of_int songid;
                                              string_of_float time])

let seekcur client time =
  Mpd.Client.send client (String.concat " " ["seekcur"; string_of_float time])
