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

open OUnit2
open Mpd
open Test_configuration

let init_client () =
  let connection = Mpd.Connection.initialize host port in
  Mpd.Client.initialize connection

let test_connection_initialize test_ctxt =
  let connection = Mpd.Connection.initialize host port in
  let _ = assert_equal ~printer:(fun s -> s) host (Connection.hostname connection) in
  let _ = assert_equal ~printer:string_of_int port (Connection.port connection) in
  Mpd.Connection.close connection

let test_client_send test_ctxt =
  let client = init_client () in
  let _ = (
    match Mpd.Client.send client "ping" with
    | Error _ -> assert_equal ~msg:"This should not has been reached" false true
    | Ok response_opt -> match response_opt with
      | None -> assert_equal true true
      | Some response -> assert_equal ~msg:"This should not has been reached" false true
  )
  in
  Mpd.Client.close client

let test_client_banner test_ctxt =
  let client = init_client () in
  let pattern = "MPD [0-9].[0-9][0-9].[0-9]" in
  let banner = Mpd.Client.mpd_banner client in
  let msg = Printf.sprintf "Banner : %s" banner in
  let _ = assert_equal true ~msg Str.(string_match (regexp pattern) banner 0) in
  Mpd.Client.close client

let test_client_status test_ctxt =
  let client = init_client () in
  let _ = match Client.status client with
    | Error message -> assert_equal ~printer:(fun _ -> "This should not have been reached") true false
    | Ok status -> let state = Mpd.(Status.string_of_state (Status.state status)) in
      assert_equal ~printer:(fun s -> s) "stop" state
  in
  Mpd.Client.close client

let test_client_ping test_ctxt =
  let client = init_client () in
  let _ = match Mpd.Client.ping client with
  | Error _ -> assert_equal ~msg:"This should not has been reached" false true
  | Ok response_opt -> match response_opt with
    | None -> assert_equal true true
    | Some response -> assert_equal ~msg:"This should not has been reached" false true
  in
  Mpd.Client.close client

let test_client_tagtypes test_ctxt =
  let client = init_client () in
  let tagtypes = Mpd.Client.tagtypes client in
  let _ = assert_equal ~printer:string_of_bool true (List.length tagtypes > 0) in
  assert_equal ~printer:string_of_bool true (List.mem "Artist" tagtypes)

let tests =
  "Connection and client tests" >:::
    [
      "Connection initialize test" >:: test_connection_initialize;
      "Client send test" >:: test_client_send;
      "Client banner test" >:: test_client_banner;
      "Client status test" >:: test_client_status;
      "Client ping test" >:: test_client_ping;
      "Client tagtypes" >:: test_client_tagtypes
    ]
