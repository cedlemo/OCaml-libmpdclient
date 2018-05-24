(*
 * Copyright 2018 Cedric LE MOIGNE, cedlemo@gmx.com
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
open Lwt
open Test_configuration


module Cnx_lwt = Connection_lwt
module Clt_lwt = Client_lwt

let init_client () =
  Cnx_lwt.initialize host port
  >>= fun connection ->
  Clt_lwt.initialize connection

let test_connection_initialize test_ctxt =
  ignore(Lwt_main.run begin
      Cnx_lwt.initialize host port
      >>= fun connection ->
      Cnx_lwt.hostname connection
      >>= fun h ->
      let _ = assert_equal ~printer:(fun s -> s) host h  in
      Cnx_lwt.port connection
      >>= fun p ->
      let _ = assert_equal ~printer:string_of_int port p in
      Cnx_lwt.close connection
    end)

let test_client_send test_ctxt =
  ignore(Lwt_main.run begin
      init_client ()
      >>= fun client ->
      Clt_lwt.send client "ping"
      >>= fun response ->
      let _ = match response with
        | Error _ -> assert_equal ~msg:"This should not has been reached" false true
        | Ok response_opt -> match response_opt with
          | None -> assert_equal true true
          | Some response -> let msg = Printf.sprintf "response: -%s-" response in
            assert_equal ~msg false true
      in
      Clt_lwt.close client
    end)

let test_client_banner test_ctxt =
  ignore(Lwt_main.run begin
      init_client ()
      >>= fun client ->
      let pattern = "MPD [0-9].[0-9][0-9].[0-9]" in
      Clt_lwt.mpd_banner client
      >>= fun banner ->
      let msg = Printf.sprintf "Banner : %s" banner in
      let _ = assert_equal true ~msg Str.(string_match (regexp pattern) banner 0) in
      Clt_lwt.close client
    end)

let test_client_status test_ctxt =
  ignore(Lwt_main.run begin
      init_client ()
      >>= fun client ->
      Clt_lwt.status client
      >>= function
      | Error message ->
        assert_equal ~printer:(fun _ -> "This should not have been reached") true false;
        Lwt.return_unit
      | Ok status -> let state = Mpd.(Status.string_of_state (Status.state status)) in
        assert_equal ~printer:(fun s -> s) "stop" state;
        Lwt.return_unit
        >>= fun () ->
        Clt_lwt.close client
    end)

let tests =
  "Connection and client lwt tests" >:::
  [
    "Connection lwt initialize test" >:: test_connection_initialize;
    "Client lwt send test" >:: test_client_send;
    "Client lwt bander" >:: test_client_banner;
    "Client lwt status" >:: test_client_status;
  ]
