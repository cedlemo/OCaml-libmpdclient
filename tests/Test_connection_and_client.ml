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

module Clt = Mpd.Client
module Cnx = Mpd.Connection
module TU = Test_utils

let msg = "This should not has been reached"
let printer = TU.printer

let test_connection_initialize _test_ctxt =
  let connection = Cnx.initialize host port in
  let () = assert_equal ~printer host (Cnx.hostname connection) in
  let () = assert_equal ~printer:string_of_int port (Cnx.port connection) in
  Cnx.close connection

let test_client_send _test_ctxt =
  TU.run_test begin fun client ->
    match Clt.send_command client "ping" with
    | Error _ -> assert_equal ~msg false true
    | Ok response_opt -> match response_opt with
      | None -> assert_equal true true
      | Some _response -> assert_equal ~msg false true
  end

let test_client_send_bad_command _test_ctxt =
  TU.run_test begin fun client ->
    match Clt.send_command client "badcommand" with
    | Error (ack_val, ack_cmd_num, ack_cmd, ack_message)  ->
      let () = assert_equal Protocol.Unknown ack_val  in
      let () = assert_equal ~printer:string_of_int 0 ack_cmd_num in
      let () = assert_equal ~printer "" ack_cmd in
      assert_equal ~printer "unknown command \"badcommand\"" ack_message
    | Ok _ -> assert_equal ~msg false true
  end

let test_client_banner _test_ctxt =
  TU.run_test begin fun client ->
    let pattern = "MPD [0-9].[0-9][0-9].[0-9]" in
    let banner = Clt.mpd_banner client in
    let msg = Printf.sprintf "Banner : %s" banner in
    assert_equal true ~msg Str.(string_match (regexp pattern) banner 0)
  end

let test_client_status _test_ctxt =
  TU.run_test begin fun client ->
    match Client.status client with
    | Error message ->
      assert_equal ~printer:(fun _ -> message) true false
    | Ok status ->
      let state = Mpd.(Status.string_of_state (Status.state status)) in
      assert_equal ~printer:(fun s -> s) "stop" state
  end

let test_client_ping _test_ctxt =
  TU.run_test begin fun client ->
    match Clt.ping client with
    | Error _ -> assert_equal ~msg false true
    | Ok response_opt ->
      match response_opt with
      | None -> assert_equal true true
      | Some _response -> assert_equal ~msg false true
  end

let test_client_tagtypes _test_ctxt =
  TU.run_test begin fun client ->
    let tagtypes = Clt.tagtypes client in
    let () =
      assert_equal ~printer:string_of_bool true (List.length tagtypes > 0) in
    assert_equal ~printer:string_of_bool true (List.mem "Artist" tagtypes)
  end

let tests =
  "Connection and client tests" >:::
  [
    "Connection initialize test" >:: test_connection_initialize;
    "Client send test" >:: test_client_send;
    "Client send bad command" >:: test_client_send_bad_command;
    "Client banner test" >:: test_client_banner;
    "Client status test" >:: test_client_status;
    "Client ping test" >:: test_client_ping;
    "Client tagtypes" >:: test_client_tagtypes
  ]
