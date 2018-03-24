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

let printer = (fun s -> s)

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

let assert_state client s test_name =
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

let assert_state_w_delay client s test_name =
  Lwt_unix.sleep 2.0
  >>= fun () ->
    assert_state client s test_name


let ensure_playlist_is_loaded client =
  let queue_length () =
      Mpd.Queue_lwt.playlist client
      >|= function
        | Mpd.Queue_lwt.PlaylistError _ -> -1
        | Mpd.Queue_lwt.Playlist p -> List.length p
    in
    queue_length ()
    >>= fun l ->
      if l <= 0 then begin
        Mpd.Stored_playlists_lwt.load client "bach" ()
        >>= function
          | Error (_, _, _, message) ->
              let information = "Error when loading playlist" in
              let _ = assert_equal ~printer information message in
              Lwt.return_unit
          | Ok _ ->
              Lwt.return_unit
      end
      else Lwt.return_unit

let check_state client s =
  Mpd.Client_lwt.status client
  >|= fun status ->
    match status with
    | Error message ->
        false
    | Ok status ->
        s == (Mpd.Status.state status)

let ensure_stopped client =
  check_state client Mpd.Status.Stop
  >>= fun is_stopped ->
    if not is_stopped then
      Mpd.Playback_lwt.stop client
      >>= fun _ -> Lwt.return_unit
    else Lwt.return_unit

let test_play test_ctxt =
  run_test begin fun client ->
    ensure_playlist_is_loaded client
    >>= fun () ->
      check_state client Mpd.Status.Stop
      >>= fun is_stopped ->
        if not is_stopped then
          Mpd.Playback_lwt.stop client
          >>= fun _ -> Lwt.return_unit
        else Lwt.return_unit
        >>= fun () ->
        Mpd.Playback_lwt.play client 1
          >>= function
            | Error (_, _ , _, message) ->
                let _ = assert_equal ~printer "Unable to play " message in
                Lwt.return_unit
            | Ok _ ->
                assert_state client Mpd.Status.Play "Play command "
            >>= fun () ->
              Mpd.Playback_lwt.stop client >>= fun _ -> Lwt.return_unit
  end

let test_pause test_ctxt =
  run_test begin fun client ->
    ensure_playlist_is_loaded client
    >>= fun () ->
      ensure_stopped client
      >>= fun () ->
        Mpd.Playback_lwt.pause client false
          >>= function
          | Error (_, _ , _, message) ->
              let _ = assert_equal ~printer
                                   "Unable to disable pause "
                                   message in
              Lwt.return_unit
          | Ok _ ->
              let message = "Pause command false before play" in
              assert_state client Mpd.Status.Stop message
          >>= fun () ->
            ensure_stopped client
            >>= fun () ->
              Mpd.Playback_lwt.play client 1
              >>= fun _ ->
                Mpd.Playback_lwt.pause client true
                >>= function
                | Error (_, _ , _, message) ->
                    let _ = assert_equal ~printer "Unable to pause " message in
                    Lwt.return_unit
                | Ok _ ->
                    assert_state client Mpd.Status.Pause "Pause command true "
                    >>= fun () ->
                      Mpd.Playback_lwt.pause client false
                      >>= function
                      | Error (_, _ , _, message) ->
                          let _ = assert_equal ~printer "Unable to pause " message in
                          Lwt.return_unit
                      | Ok _ ->
                          assert_state client Mpd.Status.Play "Pause command false "
                          >>= fun () ->
                            Mpd.Playback_lwt.stop client
                            >>= function
                            | Error (_, _ , _, message) ->
                                let _ = assert_equal ~printer "Unable to stop " message in
                                Lwt.return_unit
                            | Ok _ ->
                                assert_state client Mpd.Status.Stop "Stop command at end"
  end

let test_play_next test_ctxt =
  run_test begin fun client ->
    ensure_playlist_is_loaded client
    >>= fun () ->
      ensure_stopped client
      >>= fun () ->
        Mpd.Playback_lwt.play client 1
        >>= function
          | Error (_, _, _, message) ->
              let _ = assert_equal ~printer "Unable to play " message in
              Lwt.return_unit
          | Ok _ ->
              Mpd.Playback_lwt.next client
              >>= function
                | Error (_, _, _, message) ->
                    let _  = assert_equal ~printer "Unable to next " message in
                    Lwt.return_unit
                | Ok _ ->
                    Mpd.Client_lwt.status client
                    >>= function
                      | Error message ->
                          let _ = assert_equal ~printer "Unable to get status " message in
                          Lwt.return_unit
                      | Ok status ->
                          let current = Mpd.Status.song status in
                          let _ = assert_equal ~printer:string_of_int current 2 in
                          Lwt.return_unit
  end

let test_play_previous test_ctxt =
  run_test begin fun client ->
    ensure_playlist_is_loaded client
    >>= fun () ->
      ensure_stopped client
      >>= fun () ->
        Mpd.Playback_lwt.play client 2
        >>= function
          | Error (_, _, _, message) ->
              let _ = assert_equal ~printer "Unable to play " message in
              Lwt.return_unit
          | Ok _ ->
              Mpd.Playback_lwt.previous client
              >>= function
                | Error (_, _, _, message) ->
                    let _  = assert_equal ~printer "Unable to previous " message in
                    Lwt.return_unit
                | Ok _ ->
                    Mpd.Client_lwt.status client
                    >>= function
                      | Error message ->
                          let _ = assert_equal ~printer "Unable to get status " message in
                          Lwt.return_unit
                      | Ok status ->
                          let current = Mpd.Status.song status in
                          let _ = assert_equal ~printer:string_of_int current 1 in
                          Lwt.return_unit
  end

let test_playid test_ctxt =
  run_test begin fun client ->
    ensure_playlist_is_loaded client
    >>= fun () ->
      ensure_stopped client
      >>= fun () ->
        Mpd.Playback_lwt.play client 1
        >>= function
          | Error (_, _, _, message) ->
              let _ = assert_equal ~printer "Unable to play " message in
              Lwt.return_unit
          | Ok _ ->
              Mpd.Client_lwt.status client
              >>= function
                | Error message ->
                    let _ = assert_equal ~printer "Unable to get status " message in
                    Lwt.return_unit
                | Ok status ->
                    let id = Mpd.Status.songid status in
                    ensure_stopped client
                    >>= fun () ->
                      Mpd.Playback_lwt.playid client id
                      >>= function
                        | Error (_, _, _, message) ->
                            let _ = assert_equal ~printer "Unable to playid " message in
                            Lwt.return_unit
                        | Ok _ ->
                            Mpd.Client_lwt.status client
                            >>= function
                              | Error message ->
                                  let _ = assert_equal ~printer "Unable to get status " message in
                                  Lwt.return_unit
                              | Ok status ->
                                  let id' = Mpd.Status.songid status in
                                  let _ = assert_equal ~printer:string_of_int id id' in
                                  Lwt.return_unit
  end

let test_seek test_ctxt =
  run_test begin fun client ->
    ensure_playlist_is_loaded client
    >>= fun () ->
      ensure_stopped client
      >>= fun () ->
        Mpd.Playback_lwt.seek client 1 120.0
        >>= function
          | Error (_, _, _, message) ->
              let _ = assert_equal ~printer "Unable to seek " message in
              Lwt.return_unit
          | Ok _ ->
              Mpd.Client_lwt.status client
              >>= function
                | Error message ->
                    let _ = assert_equal ~printer "Unable to get status " message in
                    Lwt.return_unit
                | Ok status ->
                    ensure_stopped client
                    >>= fun () ->
                      let elapsed = Mpd.Status.elapsed status in
                      let _ = assert_equal ~printer:string_of_float elapsed 120.0 in
                      Lwt.return_unit
  end

let test_seekid test_ctxt =
  run_test begin fun client ->
    ensure_playlist_is_loaded client
    >>= fun () ->
      ensure_stopped client
      >>= fun () ->
        Mpd.Playback_lwt.play client 1
        >>= function
          | Error (_, _, _, message) ->
              let _ = assert_equal ~printer "Unable to play " message in
              Lwt.return_unit
          | Ok _ ->
              Mpd.Client_lwt.status client
              >>= function
                | Error message ->
                    let _ = assert_equal ~printer "Unable to get status " message in
                    Lwt.return_unit
                | Ok status ->
                    let id = Mpd.Status.songid status in
                    ensure_stopped client
                    >>= fun () ->
                      Mpd.Playback_lwt.seekid client id 120.0
                      >>= function
                        | Error (_, _, _, message) ->
                            let _ = assert_equal ~printer "Unable to playid " message in
                            Lwt.return_unit
                        | Ok _ ->
                            Mpd.Client_lwt.status client
                            >>= function
                              | Error message ->
                                  let _ = assert_equal ~printer "Unable to get status " message in
                                  Lwt.return_unit
                              | Ok status ->
                                  let id' = Mpd.Status.songid status in
                                  let _ = assert_equal ~printer:string_of_int id id' in
                                  let elapsed = Mpd.Status.elapsed status in
                                  let _ = assert_equal ~printer:string_of_float elapsed 120.0 in
                                  Lwt.return_unit
  end

let test_seekcur test_ctxt =
  run_test begin fun client ->
    ensure_playlist_is_loaded client
    >>= fun () ->
      ensure_stopped client
              >>= fun () ->
                Lwt_io.print "ensure stopped"
     >>= fun () ->
        Mpd.Playback_lwt.play client 1
        >>= function
          | Error (_, _, _, message) ->
              let _ = assert_equal ~printer "Unable to play " message in
              Lwt.return_unit
          | Ok _ ->
                              Lwt_io.print "play ok"
     >>= fun () ->
       (* ensure_stopped client
              >>= fun () ->
                Lwt_io.print "stopped"
                >>= fun () -> *)
                Mpd.Playback_lwt.seekcur client 120.0
                >>= function
                  | Error (_, _, _, message) ->
                      let _  = assert_equal ~printer "Unable to seekcur " message in
                      Lwt.return_unit
                  | Ok _ ->
                      Lwt_io.print "status after seek"
                      >>= fun () ->
                        Mpd.Client_lwt.status client
                      >>= function
                        | Error message ->
                            let _ = assert_equal ~printer "Unable to get status " message in
                            Lwt.return_unit
                        | Ok status ->
                            Lwt_io.print "analyse status"
                            >>= fun () ->
                              let current = Mpd.Status.song status in
                            let _ = assert_equal ~printer:string_of_int current 1 in
                            let elapsed = Mpd.Status.elapsed status in
                            let _ = assert_equal ~printer:string_of_float elapsed 120.0 in
                            Lwt.return_unit
  end

let tests =
  "Playback_lwt and Playback_options_lwt tests" >:::
    [
      "Test play" >:: test_play;
      "Test pause" >:: test_pause;
      "Test play next" >:: test_play_next;
      "Test play previous" >:: test_play_previous;
      "Test playid" >:: test_playid;
      "Test seek" >:: test_seek;
      "Test seekid" >:: test_seekid;
      "Test seekcur" >:: test_seekcur;
    ]
