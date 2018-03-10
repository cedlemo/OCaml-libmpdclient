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

let run_test f =
  ignore(Lwt_main.run begin
    init_client ()
    >>= fun client ->
      f client
      >>= fun () ->
        Mpd.Client_lwt.close client
  end)

let test_play_pause_stop test_ctxt =
  run_test begin fun client ->
    let queue_length () =
      Mpd.Queue_lwt.playlist client
      >|= function
        | Mpd.Queue_lwt.PlaylistError _ -> -1
        | Mpd.Queue_lwt.Playlist p -> List.length p
    in
    let check_state s test_name =
      Mpd.Client_lwt.status client
      >|= fun status ->
        match status with
        | Error message ->
            assert_equal ~printer:(fun s -> test_name ^ s)
                         "Unable to get status" message
        | Ok status ->
            assert_equal ~printer:(fun s ->
              test_name ^ (Mpd.Status.string_of_state s)
            ) s (Mpd.Status.state status)
    in
    let delayed_check_state s test_name =
      Lwt_unix.sleep 2.0
      >>= fun () ->
        check_state s test_name
    in
    queue_length ()
    >>= fun l ->
      if l <= 0 then begin
        Mpd.Stored_playlists_lwt.load client "bach" ()
        >>= function
          | Error (_, _, _, message) ->
              let information = "Error when loading playlist" in
              let _ = assert_equal ~printer:(fun s -> s) information message in
              Lwt.return_unit
          | Ok _ ->
              Lwt.return_unit
      end
      else Lwt.return_unit
      >>= fun () ->
      check_state Mpd.Status.Stop "Initial state "
  end

let tests =
  "Playback and Playback_options tests" >:::
    [
      "Test play pause stop" >:: test_play_pause_stop
    ]
