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
let queue_length = TU.queue_length

let test_stored_playlists_listplaylists _test_ctxt =
  TU.run_test_on_playlist begin fun client ->
    match Mpd.Stored_playlists.listplaylists client with
    | Error message -> TU.bad_branch message
    | Ok playlists ->
      let () = assert_equal ~printer:string_of_int 2 (List.length playlists) in
      let hd = List.hd playlists in
      let tail = List.hd (List.tl playlists) in
      let test = "bach" = hd || "bach1" = hd in
      let () = assert_bool "First playlist" test in
      let test' = "bach" = tail || "bach1" = tail in
      assert_bool "Last playlist" test'
  end

let test_stored_playlists_load_playlist_and_clear _test_ctxt =
  TU.run_test begin fun client ->
    match Mpd.Stored_playlists.load client "bach" () with
    | Error (_, _, _, message) -> TU.bad_branch message
    | Ok _ ->
      let len = queue_length client in
      let () =  assert_equal ~printer:string_of_int 11 len in
      match Mpd.Queue.clear client with
      | Error (_, _, _, message) -> TU.bad_branch message
      | Ok _ -> begin
          let len = queue_length client in
          assert_equal ~printer:string_of_int 0 len
        end
  end

let test_queue_list _test_ctxt =
  TU.run_test_on_playlist begin fun client ->
    match Mpd.Stored_playlists.load client "bach" () with
    | Error (_, _, _, message) -> TU.bad_branch message
    | Ok _ ->
      match Mpd.Queue.playlist client with
      | PlaylistError message -> TU.bad_branch message
      | Playlist songs ->
        let song_names = List.map Mpd.Song.title songs in
        let same = TU.compare TU.queue song_names in
        assert_bool "Songs titles do not match" same
  end

let test_queue_playlistid _test_ctxt =
  TU.run_test_on_playlist begin fun client ->
    match Mpd.Stored_playlists.load client "bach" () with
    | Error (_, _, _, message) -> TU.bad_branch message
    | Ok _ ->
      match Mpd.Queue.playlist client with
      | PlaylistError message -> TU.bad_branch message
      | Playlist songs ->
        let check_song n =
          let song = List.nth songs n in
          let id = Mpd.Song.id song in
          match Mpd.Queue.playlistid client id with
          | Error message -> TU.bad_branch message
          | Ok song' ->
            let title = Mpd.Song.title song in
            let title' = Mpd.Song.title song' in
            assert_equal ~printer title title'
        in
        let () = check_song 0 in
        let () = check_song 1 in
        let () = check_song 5 in
        check_song 10
  end

let tests =
  "Queue and playlists tests" >:::
  [
    "test stored playlists listplaylists" >:: test_stored_playlists_listplaylists;
    "test stored playlists load playlist and clear" >:: test_stored_playlists_load_playlist_and_clear;
    "test queue playlist" >:: test_queue_list;
    "test queue playlistid" >:: test_queue_playlistid;
  ]
