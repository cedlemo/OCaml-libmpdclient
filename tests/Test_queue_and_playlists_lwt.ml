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

open Lwt.Infix
open OUnit2
module TU = Test_utils

let printer = TU.printer
let queue_length_lwt = TU.queue_length_lwt

let test_stored_playlists_listplaylists _test_ctxt =
  TU.run_test_on_playlist_lwt begin fun client ->
    Mpd.Stored_playlists_lwt.listplaylists client
    >>= fun response ->
    let () = match response with
      | Error message ->
        assert_equal ~printer "This should not have been reached" message
      | Ok playlists ->
        let () = assert_equal ~printer:string_of_int 2 (List.length playlists) in
        let hd = List.hd playlists in
        let tail = List.hd (List.tl playlists) in
        let test = "bach" = hd || "bach1" = hd in
        let () = assert_bool "First playlist" test in
        let test' = "bach" = tail || "bach1" = tail in
        assert_bool "Last playlist" test'
    in Lwt.return_unit
  end

let test_stored_playlists_load_playlist_and_clear _test_ctxt =
  TU.run_test_lwt begin fun client ->
    Mpd.Stored_playlists_lwt.load client "bach" ()
    >>= function
    | Error (_, _, _, message) ->
      assert_equal ~printer "This should not have been reached " message;
      Lwt.return_unit
    | Ok _ ->
      queue_length_lwt client
      >>= fun len ->
      let () =  assert_equal ~printer:string_of_int 11 len in
      Mpd.Queue_lwt.clear client
      >>= function
      | Error (_, _, _, message) ->
        assert_equal ~printer "This should not have been reached " message;
        Lwt.return_unit
      | Ok _ -> begin
          queue_length_lwt client
          >>= fun len ->
          assert_equal ~printer:string_of_int 0 len;
          Lwt.return_unit
        end
  end

let test_queue_list _test_ctxt =
  TU.run_test_on_playlist_lwt begin fun client ->
    Mpd.Stored_playlists_lwt.load client "bach" ()
    >>= fun response ->
    match response with
    | Error (_, _, _, message) -> TU.bad_branch message; Lwt.return_unit
    | Ok _ ->
      Mpd.Queue_lwt.playlist client
      >>= fun response ->
      match response with
      | PlaylistError message -> TU.bad_branch message; Lwt.return_unit
      | Playlist songs ->
        let song_names = List.map Mpd.Song.title songs in
        let same = TU.compare TU.queue song_names in
        let () = assert_bool "Songs titles do not match" same
        in
        Lwt.return_unit
  end

let test_queue_playlistid _test_ctxt =
  TU.run_test_on_playlist_lwt begin fun client ->
    Mpd.Stored_playlists_lwt.load client "bach" ()
    >>= function
    | Error (_, _, _, message) -> TU.bad_branch message; Lwt.return_unit
    | Ok _ ->
       Mpd.Queue_lwt.playlist client
       >>= function
       | PlaylistError message -> TU.bad_branch message; Lwt.return_unit
       | Playlist songs ->
         let check_song n =
           let song = List.nth songs n in
           let id = Mpd.Song.id song in
           Mpd.Queue_lwt.playlistid client id
           >>= function
           | Error message -> TU.bad_branch message; Lwt.return_unit
           | Ok song' ->
             let title = Mpd.Song.title song in
             let title' = Mpd.Song.title song' in
             assert_equal ~printer title title';
             Lwt.return_unit
        in
        check_song 0
        >>= fun () -> check_song 1
        >>= fun () -> check_song 5
        >>= fun () -> check_song 10
  end


let tests =
  "Queue and playlists lwt tests" >:::
  [
    "test stored playlists listplaylists" >:: test_stored_playlists_listplaylists;
    "test stored playlists load playlist and clear" >:: test_stored_playlists_load_playlist_and_clear;
    "test queue playlist" >:: test_queue_list;
    "test queue playlistid" >:: test_queue_playlistid;
  ]
