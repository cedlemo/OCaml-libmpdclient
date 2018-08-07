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
open Test_configuration

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

let assert_state_w_delay _client s test_name =
  let () = Unix.sleep 2 in
  assert_state s test_name

let check_state client s =
  match Mpd.Client.status client with
  | Error _message ->
      false
  | Ok status ->
       s == Mpd.Status.state status

let test_play _test_ctxt =
  run_test begin fun client ->
    let _ = ensure_playlist_is_loaded client in
    let _ = if not (check_state client Mpd.Status.Stop) then
      ignore(Mpd.Playback.stop client)
    in
    let _ = match Mpd.Playback.play client 1 with
      | Error (_, _ , _, message) ->
          assert_equal ~printer "Unable to play " message
      | Ok _ ->
          assert_state client Mpd.Status.Play "Play command "
    in Mpd.Playback.stop client
  end

let test_pause _test_ctxt =
  run_test begin fun client ->
    let _ = ensure_playlist_is_loaded client in
    let _ = if not (check_state client Mpd.Status.Stop) then
      ignore(Mpd.Playback.stop client)
    in
    let _ = match Mpd.Playback.pause client false with
      | Error (_, _ , _, message) ->
          assert_equal ~printer "Unable to disable pause " message
      | Ok _ ->
          assert_state client Mpd.Status.Stop "Pause command false before play"
    in
    let _ = if (check_state client Mpd.Status.Stop) then
      ignore(Mpd.Playback.play client 1)
    in
    let _ = match Mpd.Playback.pause client true with
      | Error (_, _ , _, message) ->
          assert_equal ~printer "Unable to pause " message
      | Ok _ ->
          assert_state client Mpd.Status.Pause "Pause command true "
    in
    let _ = match Mpd.Playback.pause client false with
      | Error (_, _ , _, message) ->
          assert_equal ~printer "Unable to replay " message
      | Ok _ ->
          assert_state client Mpd.Status.Play "Pause command false "
    in
      Mpd.Playback.stop client
end

let test_play_next _test_ctxt =
  run_test begin fun client ->
    let _ = ensure_playlist_is_loaded client in
    let _ = if not (check_state client Mpd.Status.Stop) then
      ignore(Mpd.Playback.stop client)
    in
    let _ = if (check_state client Mpd.Status.Stop) then
      ignore(Mpd.Playback.play client 1)
    in
    match Mpd.Playback.next client with
    | Error (_, _ , _, message) ->
        assert_equal ~printer "Unable to play next song " message
    | Ok _ -> match Mpd.Client.status client with
        | Error message ->
            assert_equal ~printer "Unable to get current status " message
        | Ok status -> let current = Mpd.Status.song status in
            assert_equal ~printer:string_of_int current 2
  end

let test_play_previous _test_ctxt =
  run_test begin fun client ->
    let _ = ensure_playlist_is_loaded client in
    let _ = if not (check_state client Mpd.Status.Stop) then
      ignore(Mpd.Playback.stop client)
    in
    let _ = if (check_state client Mpd.Status.Stop) then
      ignore(Mpd.Playback.play client 2)
    in
    match Mpd.Playback.previous client with
    | Error (_, _ , _, message) ->
        assert_equal ~printer "Unable to play previous song " message
    | Ok _ -> match Mpd.Client.status client with
        | Error message ->
            assert_equal ~printer "Unable to get current status " message
        | Ok status -> let current = Mpd.Status.song status in
            assert_equal ~printer:string_of_int current 1
  end

let test_playid _test_ctxt =
  run_test begin fun client ->
    let _ = ensure_playlist_is_loaded client in
    let _ = if not (check_state client Mpd.Status.Stop) then
      ignore(Mpd.Playback.stop client)
    in
    let _ = match Mpd.Playback.play client 1 with
      | Error (_, _ , _, message) ->
          assert_equal ~printer "Unable to play " message
      | Ok _ ->
          match Mpd.Client.status client with
          | Error message ->
              assert_equal ~printer "Unable to get current status " message
          | Ok status ->
              let id = Mpd.Status.songid status in
              let _ = Mpd.Playback.stop client in
              match Mpd.Playback.playid client id with
              | Error (_, _ , _, message) ->
                  assert_equal ~printer "Unable to play " message
              | Ok _ ->
                  match Mpd.Client.status client with
                  | Error message ->
                      assert_equal ~printer "Unable to get current status " message
                  | Ok status ->
                      let id' = Mpd.Status.songid status in
                      assert_equal ~printer:string_of_int id id'

    in Mpd.Playback.stop client
  end

let test_seek _test_ctxt =
  run_test begin fun client ->
    let _ = ensure_playlist_is_loaded client in
    let _ = if not (check_state client Mpd.Status.Stop) then
      ignore(Mpd.Playback.stop client)
    in
    let _ = match Mpd.Playback.seek client 1 120.0 with
      | Error (_, _ , _, message) ->
          assert_equal ~printer "Unable to play " message
      | Ok _ ->
          match Mpd.Client.status client with
          | Error message ->
              assert_equal ~printer "Unable to get current status " message
          | Ok status ->
              let elapsed = Mpd.Status.elapsed status in
              assert_equal ~printer:string_of_float elapsed 120.0
    in Mpd.Playback.stop client
  end

let test_seekid _test_ctxt =
  run_test begin fun client ->
    let _ = ensure_playlist_is_loaded client in
    let _ = if not (check_state client Mpd.Status.Stop) then
      ignore(Mpd.Playback.stop client)
    in
    let _ = match Mpd.Playback.play client 1 with
      | Error (_, _ , _, message) ->
          assert_equal ~printer "Unable to play " message
      | Ok _ ->
          match Mpd.Client.status client with
          | Error message ->
              assert_equal ~printer "Unable to get current status " message
          | Ok status ->
              let id = Mpd.Status.songid status in
              let _ = Mpd.Playback.stop client in
              match Mpd.Playback.seekid client id 120.0 with
              | Error (_, _ , _, message) ->
                  assert_equal ~printer "Unable to play " message
              | Ok _ ->
                  match Mpd.Client.status client with
                  | Error message ->
                      assert_equal ~printer "Unable to get current status " message
                  | Ok status ->
                      let elapsed = Mpd.Status.elapsed status in
                      assert_equal ~printer:string_of_float elapsed 120.0

    in Mpd.Playback.stop client
  end

let test_seekcur _test_ctxt =
  run_test begin fun client ->
    let _ = ensure_playlist_is_loaded client in
    let _ = if not (check_state client Mpd.Status.Stop) then
      ignore(Mpd.Playback.stop client)
    in
    let _ = match Mpd.Playback.play client 1 with
      | Error (_, _ , _, message) ->
          assert_equal ~printer "Unable to play " message
      | Ok _ ->
          let _ = Mpd.Playback.stop client in
          match Mpd.Playback.seekcur client 120.0 with
          | Error (_, _ , _, message) ->
              assert_equal ~printer "Unable to play " message
          | Ok _ ->
              match Mpd.Client.status client with
              | Error message ->
                  assert_equal ~printer "Unable to get current status " message
              | Ok status ->
                  let elapsed = Mpd.Status.elapsed status in
                  assert_equal ~printer:string_of_float elapsed 120.0
    in Mpd.Playback.stop client
  end

let test_consume _test_ctxt =
  run_test begin fun client ->
   let _ = ensure_playlist_is_loaded client in
   let _ = if not (check_state client Mpd.Status.Stop) then
      ignore(Mpd.Playback.stop client)
   in
   match Mpd.Client.status client with
   | Error message ->
       assert_equal ~printer "Unable to get status " message
   | Ok status ->
       let consume = Mpd.Status.consume status in
       match Mpd.Playback_options.consume client (not consume) with
       | Error (_, _, _, message) ->
           assert_equal ~printer "Unable to set consume " message
       | Ok _ ->
           match Mpd.Client.status client with
           | Error message ->
               assert_equal ~printer "Unable to get status " message
           | Ok status ->
               let consume' = Mpd.Status.consume status in
               assert_equal ~printer:string_of_bool (not consume) consume'
  end

let tests =
  "Playback and Playback_options tests" >:::
    [
      "test play command" >:: test_play;
      "test pause command" >:: test_pause;
      "test play next command" >:: test_play_next;
      "test play previous command" >:: test_play_previous;
      "test playid command" >:: test_playid;
      "test seek command" >:: test_seek;
      "test seekid command" >:: test_seekid;
      "test consume command" >:: test_consume;
    ]
