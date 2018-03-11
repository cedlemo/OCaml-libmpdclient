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

let run_test f =
  let client = init_client () in
  let _ = f client in
  Mpd.Client.close client

let test_play_pause_stop test_ctxt =
  run_test (fun client ->
    let queue_length () = match Mpd.Queue.playlist client with
                          | Mpd.Queue.PlaylistError _ -> -1
                          | Mpd.Queue.Playlist p -> List.length p
    in
    let check_state s test_name =
      match Mpd.Client.status client with
      | Error message ->
          assert_equal ~printer:(fun s -> test_name ^ s)
                       "Unable to get status" message
      | Ok status ->
          assert_equal ~printer:(fun s ->
            test_name ^ (Mpd.Status.string_of_state s)
          ) s (Mpd.Status.state status)
    in
    let check_state_w_delay s test_name =
      let _ = Unix.sleep 2 in
      check_state s test_name
    in
    if queue_length () <= 0 then (
      match Mpd.Stored_playlists.load client "bach" () with
      | Error (_, _, _, message) ->
          let information = "Error when loading playlist" in
          assert_equal ~printer:(fun s -> s)  information message
      | Ok _ ->
          ()
    );
    let _ = check_state Mpd.Status.Stop "Initial state " in
    let _ = (
      match Mpd.Playback.pause client false with
      | Error (_, _ , _, message) ->
          assert_equal ~printer:(fun s -> s) "Unable to disable pause " message
      | Ok _ ->
          check_state_w_delay Mpd.Status.Stop "Pause command false before play"
    ) in
    let _ = (
      match Mpd.Playback.play client 1 with
      | Error (_, _ , _, message) ->
          assert_equal ~printer:(fun s -> s) "Unable to play " message
      | Ok _ ->
          check_state_w_delay Mpd.Status.Play "Play command "
    ) in
    let _ = (
      match Mpd.Playback.pause client true with
      | Error (_, _ , _, message) ->
          assert_equal ~printer:(fun s -> s) "Unable to pause " message
      | Ok _ ->
          check_state_w_delay Mpd.Status.Pause "Pause command true "
    ) in
    let _ = (
      match Mpd.Playback.pause client false with
      | Error (_, _ , _, message) ->
          assert_equal ~printer:(fun s -> s) "Unable to replay " message
      | Ok _ ->
          check_state_w_delay Mpd.Status.Play "Pause command false "
    ) in
    match Mpd.Playback.stop client with
    | Error (_, _ , _, message) ->
        assert_equal ~printer:(fun s -> s) "Unable to stop " message
    | Ok _ ->
        check_state_w_delay Mpd.Status.Stop "Stop command at end"
  )

let tests =
  "Playback and Playback_options tests" >:::
    [
      "test play pause stop command" >:: test_play_pause_stop
    ]
