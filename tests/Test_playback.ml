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
  module TU = Test_utils

  let printer = TU.printer

  let test_play _test_ctxt =
    TU.run_test begin fun client ->
      match Mpd.Playback.play client 1 with
      | Error (_, _ , _, message) ->
          assert_equal ~printer "Unable to play " message
      | Ok _ ->
          TU.assert_state client Mpd.Status.Play "Play command "
    end

  let test_pause_true_when_status_play _test_ctxt =
    TU.run_test begin fun client ->
      match Mpd.Playback.play client 1 with
      | Error (_, _ , _, message) ->
          assert_equal ~printer "Unable to play " message
      | Ok _ ->  match Mpd.Playback.pause client true with
          | Error (_, _ , _, message) ->
              assert_equal ~printer "Unable to pause " message
          | Ok _ ->
              TU.assert_state client Mpd.Status.Pause "Pause command true "
    end

  let test_pause_false_when_status_pause _test_ctxt =
    TU.run_test begin fun client ->
      match Mpd.Playback.play client 1 with
      | Error (_, _ , _, message) ->
          assert_equal ~printer "Unable to play " message
      | Ok _ ->let () = ignore(Mpd.Playback.pause client true) in
          match Mpd.Playback.pause client false with
          | Error (_, _ , _, message) ->
              assert_equal ~printer "Unable to replay " message
          | Ok _ ->
              TU.assert_state client Mpd.Status.Play "Pause command false "
    end

  let test_play_next _test_ctxt =
    TU.run_test begin fun client ->
      match Mpd.Playback.play client 1 with
      | Error (_, _ , _, message) ->
          assert_equal ~printer "Unable to play " message
      | Ok _ -> match Mpd.Client.status client with
          | Error message ->
            assert_equal ~printer "Unable to get current status " message
          | Ok status -> let first = Mpd.Status.song status in
            match Mpd.Playback.next client with
            | Error (_, _ , _, message) ->
              assert_equal ~printer "Unable to play next song " message
            | Ok _ -> match Mpd.Client.status client with
              | Error message ->
                  assert_equal ~printer "Unable to get current status " message
              | Ok status -> let current = Mpd.Status.song status in
                  assert_equal ~printer:string_of_int (first + 1) current
    end

  let test_play_previous _test_ctxt =
    TU.run_test begin fun client ->
      match Mpd.Playback.play client 2 with
      | Error (_, _ , _, message) ->
          assert_equal ~printer "Unable to play " message
      | Ok _ ->
          match Mpd.Playback.previous client with
          | Error (_, _ , _, message) ->
              assert_equal ~printer "Unable to play previous song " message
          | Ok _ -> match Mpd.Client.status client with
              | Error message ->
                  assert_equal ~printer "Unable to get current status " message
              | Ok status -> let current = Mpd.Status.song status in
                  assert_equal ~printer:string_of_int 1 current
    end

  let test_playid _test_ctxt =
    TU.run_test begin fun client ->
      match Mpd.Playback.play client 1 with
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
    end

  let test_seek _test_ctxt =
    TU.run_test begin fun client ->
    match Mpd.Playback.seek client 1 120.0 with
      | Error (_, _ , _, message) ->
          assert_equal ~printer "Unable to play " message
      | Ok _ ->
          match Mpd.Client.status client with
          | Error message ->
              assert_equal ~printer "Unable to get current status " message
          | Ok status ->
              let elapsed = Mpd.Status.elapsed status in
              assert_equal ~printer:string_of_float elapsed 120.0
    end

  let test_seekid _test_ctxt =
    TU.run_test begin fun client ->
      match Mpd.Playback.play client 1 with
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
    end

  let test_seekcur _test_ctxt =
    TU.run_test begin fun client ->
      match Mpd.Playback.play client 1 with
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
    end

  let test_consume _test_ctxt =
    TU.run_test begin fun client ->
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
                let () =
                  assert_equal ~printer:string_of_bool (not consume) consume'
                in if consume' then (* disable consume mode if on *)
                  ignore(Mpd.Playback_options.consume client (not consume'))
    end

  let tests =
    "Playback and Playback_options tests" >:::
      [
        (* "test play command" >:: test_play; *)
        (*"test pause true when status play" >:: test_pause_true_when_status_play;
        "test pause false when status pause" >:: test_pause_false_when_status_pause;
        "test play next command" >:: test_play_next;
        "test play previous command" >:: test_play_previous;
        "test playid command" >:: test_playid;
        "test seek command" >:: test_seek;
        "test seekid command" >:: test_seekid;
        "test consume command" >:: test_consume; *)
      ]
