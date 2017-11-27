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

open OUnit2
open Mpd

let host = "127.0.0.1"
let port = 6600

let init_client () =
  let connection = Mpd.Connection.initialize host port in
  Mpd.Client.initialize connection

let test_connection_initialize test_ctxt =
  let connection = Mpd.Connection.initialize host port in
  let _ = assert_equal ~printer:(fun s -> s) host (Connection.hostname connection) in
  assert_equal ~printer:string_of_int port (Connection.port connection)

let test_client_banner test_ctxt =
  let client = init_client () in
  assert_equal ~printer:(fun x -> x) "OK MPD 0.19.0\n" (Mpd.Client.mpd_banner client)

let test_client_status test_ctxt =
  let client = init_client () in
  match Client.status client with
  | Error message -> assert_equal ~printer:(fun _ -> "This should not have been reached") true false
  | Ok status -> let state = Mpd.(Status.string_of_state (Status.state status)) in
    assert_equal ~printer:(fun s -> s) "stop" state

let tests =
  "Connection and client tests" >:::
    [
      "Connection initialize test" >:: test_connection_initialize;
      "Client banner test" >:: test_client_banner;
      "Client status test" >:: test_client_status
    ]
