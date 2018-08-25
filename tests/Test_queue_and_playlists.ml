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
  end

let test_stored_playlists_load_playlist_and_clear _test_ctxt =
  TU.run_test begin fun client ->
    match Mpd.Stored_playlists.load client "bach" () with
    | Error (_, _, _, message) ->
      assert_equal ~printer "This should not have been reached " message
    | Ok _ ->
      let len = queue_length client in
      let () =  assert_equal ~printer:string_of_int 11 len in
      match Mpd.Queue.clear client with
      | Error (_, _, _, message) ->
        assert_equal ~printer "This should not have been reached " message
      | Ok _ -> begin
          let len = queue_length client in
          assert_equal ~printer:string_of_int 0 len
        end
  end

let test_music_database_find _test_ctxt =
  let open Mpd.Music_database in
  TU.run_test_on_playlist begin fun client ->
    match find client [(Mpd_tag Artist, "Bach JS")] () with
    | Error (_, _, _, error) ->
      assert_equal ~printer "This should not have been reached " error
    | Ok songs -> assert_equal 11 (List.length songs)
  end

let test_music_database_findadd _test_ctxt =
  let open Mpd.Music_database in
  TU.run_test_on_playlist begin fun client ->
    match findadd client [(Mpd_tag Artist, "Bach JS")] with
    | Error (_, _, _, error) ->
      assert_equal ~printer "This should not have been reached " error
    | Ok _ -> let queue = Mpd.Queue.playlist client in
      let queue_length = match queue with
        | Mpd.Queue.PlaylistError _ -> -1
        | Mpd.Queue.Playlist p -> List.length p
      in
      assert_equal ~printer:(fun i -> string_of_int i) 11 queue_length
  end

let test_music_database_search _test_ctxt =
  let open Mpd.Music_database in
  TU.run_test begin fun client ->
    match search client [(Mpd_tag Artist, "bACH js")] () with
    | Error (_, _, _, error) ->
      assert_equal ~printer "This should not have been reached " error
    | Ok songs -> assert_equal 11 (List.length songs)
  end

let test_music_database_searchadd _test_ctxt =
  let open Mpd.Music_database in
  TU.run_test_on_playlist begin fun client ->
    match searchadd client [(Mpd_tag Artist, "bACH js")] with
    | Error (_, _, _, error) ->
      assert_equal ~printer "This should not have been reached " error
    | Ok _ -> let queue = Mpd.Queue.playlist client in
      let queue_length = match queue with
        | Mpd.Queue.PlaylistError _ -> -1
        | Mpd.Queue.Playlist p -> List.length p
      in
      assert_equal ~printer:(fun i -> string_of_int i) 11 queue_length
  end

let test_music_database_searchaddpl _test_ctxt =
  let open Mpd.Music_database in
  TU.run_test_on_playlist begin fun client ->
    let new_playlist = "searchaddpl_new_playlist" in
    let get_playlist_number () =
      match Mpd.Stored_playlists.listplaylists client with
      | Error message ->
        let () = assert_equal ~printer "This should not have been reached " message in
        -1
      | Ok playlists -> List.length playlists
    in
    match searchaddpl client new_playlist [(Mpd_tag Artist, "bACH js")] with
    | Error (_, _, _, error) ->
      assert_equal ~printer "This should not have been reached " error
    | Ok _ ->
      let () = assert_equal 3 (get_playlist_number ()) in
      let () = ignore(Mpd.Stored_playlists.rm client new_playlist) in
      assert_equal 2 (get_playlist_number ())
  end

let test_music_database_count _test_ctxt =
  let open Mpd.Music_database in
  TU.run_test begin fun client ->
    match count client [] ?group:(Some Artist) () with
    | Error message -> assert_equal ~printer:(fun s -> s) "This should not have been reached " message
    | Ok counts -> assert_equal ~printer:(fun s -> string_of_int s) 1 (List.length counts)
  end

let tests =
  "Queue and playlists tests" >:::
  [
    "test stored playlists listplaylists" >:: test_stored_playlists_listplaylists;
    "test stored playlists load playlist and clear" >:: test_stored_playlists_load_playlist_and_clear;
    "test music database find" >:: test_music_database_find;
    "test music database findadd" >:: test_music_database_findadd;
    "test music database search" >:: test_music_database_search;
    "test music database searchadd" >:: test_music_database_searchadd;
    "test music database searchaddpl" >:: test_music_database_searchaddpl;
    "test music database count" >:: test_music_database_count;
  ]
