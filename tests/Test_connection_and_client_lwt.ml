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

let host = "127.0.0.1"
let port = 6600

let init_client () =
  Connection_lwt.initialize host port
  >>= fun connection ->
    Client_lwt.initialize connection

let test_connection_initialize test_ctxt =
  ignore(Lwt_main.run begin
  Connection_lwt.initialize host port
  >>= fun connection ->
    Connection_lwt.hostname connection
    >>= fun h ->
      let _ = assert_equal ~printer:(fun s -> s) host h  in
      Connection_lwt.port connection
      >>= fun p ->
      let _ = assert_equal ~printer:string_of_int port p in
      Connection_lwt.close connection
  end)

let test_client_send test_ctxt =
  ignore(Lwt_main.run begin
  init_client ()
  >>= fun client ->
    Mpd.Client_lwt.send client "ping"
    >>= fun response ->
      let _ = match response with
        | Error _ -> assert_equal ~msg:"This should not has been reached" false true
        | Ok response_opt -> match response_opt with
          | None -> assert_equal true true
          | Some response -> let msg = Printf.sprintf "response: -%s-" response in
              assert_equal ~msg false true
      in
      Mpd.Client_lwt.close client
  end)

let tests =
  "Connection and client lwt tests" >:::
    [
      "Connection initialize test" >:: test_connection_initialize;
      "Client send test" >:: test_client_send;
    ]
