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

let host = "127.0.0.1"
let port = 6600

let printer = (fun s -> s)

let init_client () =
  let connection = Mpd.Connection.initialize host port in
  Mpd.Client.initialize connection

let run_test f =
  let client = init_client () in
  let _ = f client in
  Mpd.Client.close client

let ensure_playlist_is_loaded client =
  let queue_length () = match Mpd.Queue.playlist client with
                        | Mpd.Queue.PlaylistError _ -> -1
                        | Mpd.Queue.Playlist p -> List.length p
  in
  if queue_length () <= 0 then (
    match Mpd.Stored_playlists.load client "bach" () with
    | Error (_, _, _, message) ->
        let information = "Error when loading playlist" in
        assert_equal ~printer information message
    | Ok _ ->
        ()
  )

let assert_state client s test_name =
  match Mpd.Client.status client with
  | Error message ->
      assert_equal ~printer:(fun s -> test_name ^ s)
                   "Unable to get status" message
  | Ok status ->
      assert_equal ~printer:(fun s ->
        test_name ^ (Mpd.Status.string_of_state s)
      ) s (Mpd.Status.state status)

let assert_state_w_delay client s test_name =
  let _ = Unix.sleep 2 in
  assert_state s test_name

let check_state client s =
  match Mpd.Client.status client with
  | Error message ->
      false
  | Ok status ->
       s == Mpd.Status.state status

let test_play test_ctxt =
run_test begin fun client ->
    ensure_playlist_is_loaded client in
    let _ = if !(check_state client Mpd.Status.Stop) then
      Mpd.Playback.stop client
    in
    let _ = match Mpd.Playback.play client 1 with
      | Error (_, _ , _, message) ->
          assert_equal ~printer "Unable to play " message
      | Ok _ ->
          check_state Mpd.Status.Play "Play command "
    in Mpd.Playback.stop client
end


(* let test_play_pause_stop test_ctxt =
  run_test (fun client ->
    ensure_playlist_is_loaded client in
    let _ = check_state Mpd.Status.Stop "Initial state " in
    let _ = (
      match Mpd.Playback.pause client false with
      | Error (_, _ , _, message) ->
          assert_equal ~printer "Unable to disable pause " message
      | Ok _ ->
          check_state Mpd.Status.Stop "Pause command false before play"
    ) in
    let _ = (
      match Mpd.Playback.play client 1 with
      | Error (_, _ , _, message) ->
          assert_equal ~printer "Unable to play " message
      | Ok _ ->
          check_state Mpd.Status.Play "Play command "
    ) in
    let _ = (
      match Mpd.Playback.pause client true with
      | Error (_, _ , _, message) ->
          assert_equal ~printer "Unable to pause " message
      | Ok _ ->
          check_state Mpd.Status.Pause "Pause command true "
    ) in
    let _ = (
      match Mpd.Playback.pause client false with
      | Error (_, _ , _, message) ->
          assert_equal ~printer "Unable to replay " message
      | Ok _ ->
          check_state Mpd.Status.Play "Pause command false "
    ) in
    match Mpd.Playback.stop client with
    | Error (_, _ , _, message) ->
        assert_equal ~printer "Unable to stop " message
    | Ok _ ->
        check_state Mpd.Status.Stop "Stop command at end"
  )
*)
let tests =
  "Playback and Playback_options tests" >:::
    [
      "test play command" >:: test_play
    ]
