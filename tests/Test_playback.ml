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
    let client = Mpd.Client.initialize connection in
    let () = match Mpd.Music_database.update client None with
      | Error (_, _, _, message) ->
          let information = "Error when updating database " in
          assert_equal ~printer information message
      | Ok _ -> ()
    in
    client

  let ensure_playlist_is_loaded client =
    let queue_length () = match Mpd.Queue.playlist client with
                          | Mpd.Queue.PlaylistError _ -> -1
                          | Mpd.Queue.Playlist p -> List.length p
    in
    if queue_length () <= 0 then begin
      match Mpd.Stored_playlists.load client "bach" () with
      | Error (_, _, _, message) ->
          let information = "Error when loading playlist" in
          assert_equal ~printer information message
      | Ok _ -> ()
    end

  let ensure_playback_is_stopped client =
     ignore(Mpd.Playback.stop client)

  let ensure_playlist_is_cleared client =
    ignore(Mpd.Queue.clear client)

  let run_test f =
    let client = init_client () in
    let () = ensure_playlist_is_loaded client in
    let () = ensure_playback_is_stopped client in
    let () = f client in
    let () = ensure_playback_is_stopped client in
    let () = ensure_playlist_is_cleared client in
    Mpd.Client.close client

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
      match Mpd.Playback.play client 1 with
      | Error (_, _ , _, message) ->
          assert_equal ~printer "Unable to play " message
      | Ok _ ->
          assert_state client Mpd.Status.Play "Play command "
    end

  let test_pause_true_when_status_play _test_ctxt =
    run_test begin fun client ->
      match Mpd.Playback.play client 1 with
      | Error (_, _ , _, message) ->
          assert_equal ~printer "Unable to play " message
      | Ok _ ->  match Mpd.Playback.pause client true with
          | Error (_, _ , _, message) ->
              assert_equal ~printer "Unable to pause " message
          | Ok _ ->
              assert_state client Mpd.Status.Pause "Pause command true "
    end

  let test_pause_false_when_status_pause _test_ctxt =
    run_test begin fun client ->
      match Mpd.Playback.play client 1 with
      | Error (_, _ , _, message) ->
          assert_equal ~printer "Unable to play " message
      | Ok _ ->let () = ignore(Mpd.Playback.pause client true) in
          match Mpd.Playback.pause client false with
          | Error (_, _ , _, message) ->
              assert_equal ~printer "Unable to replay " message
          | Ok _ ->
              assert_state client Mpd.Status.Play "Pause command false "
    end

  let test_play_next _test_ctxt =
    run_test begin fun client ->
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
    run_test begin fun client ->
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
    run_test begin fun client ->
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
    run_test begin fun client ->
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
    run_test begin fun client ->
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
    run_test begin fun client ->
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
    run_test begin fun client ->
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
        "test play command" >:: test_play;
        "test pause true when status play" >:: test_pause_true_when_status_play;
        "test pause false when status pause" >:: test_pause_false_when_status_pause;
        "test play next command" >:: test_play_next;
        "test play previous command" >:: test_play_previous;
        "test playid command" >:: test_playid;
        "test seek command" >:: test_seek;
        "test seekid command" >:: test_seekid;
        "test consume command" >:: test_consume;
      ]
