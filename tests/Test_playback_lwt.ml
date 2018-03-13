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

(*
let test_play_pause_stop test_ctxt =
  run_test begin fun client ->
      >>= fun () ->
        check_state Mpd.Status.Stop "Initial state "
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
            check_state Mpd.Status.Stop message
      >>= fun () ->
        Mpd.Playback_lwt.play client 1
        >>= function
        | Error (_, _ , _, message) ->
            let _ = assert_equal ~printer "Unable to play " message in
            Lwt.return_unit
        | Ok _ ->
            check_state Mpd.Status.Play "Play command "
      >>= fun () ->
        Mpd.Playback_lwt.pause client true
          >>= function
          | Error (_, _ , _, message) ->
              let _ = assert_equal ~printer "Unable to pause " message in
              Lwt.return_unit
          | Ok _ ->
              check_state Mpd.Status.Pause "Pause command true "
      >>= fun () ->
        Mpd.Playback_lwt.pause client false
          >>= function
          | Error (_, _ , _, message) ->
              let _ = assert_equal ~printer "Unable to pause " message in
              Lwt.return_unit
          | Ok _ ->
              check_state Mpd.Status.Pause "Pause command false "
      >>= fun () ->
        Mpd.Playback_lwt.stop client
        >>= function
        | Error (_, _ , _, message) ->
            let _ = assert_equal ~printer "Unable to stop " message in
            Lwt.return_unit
        | Ok _ ->
            check_state_w_delay Mpd.Status.Stop "Stop command at end"
  end
*)

let tests =
  "Playback and Playback_options tests" >:::
    [
      "Test play" >:: test_play
    ]
