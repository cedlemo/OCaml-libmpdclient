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
module TU = Test_utils

let printer = TU.printer
let queue_length = TU.queue_length

let test_music_database_find _test_ctxt =
  let open Mpd.Music_database in
  TU.run_test_on_playlist (fun client ->
      match find client [ (Mpd_tag Artist, TU.artist) ] () with
      | Error (_, _, _, error) -> TU.bad_branch error
      | Ok songs -> assert_equal 11 (List.length songs))

let test_music_database_findadd _test_ctxt =
  let open Mpd.Music_database in
  TU.run_test_on_playlist (fun client ->
      match findadd client [ (Mpd_tag Artist, TU.artist) ] with
      | Error (_, _, _, error) -> TU.bad_branch error
      | Ok _ ->
          let len = queue_length client in
          assert_equal ~printer:(fun i -> string_of_int i) 11 len)

let test_music_database_search _test_ctxt =
  let open Mpd.Music_database in
  TU.run_test (fun client ->
      match search client [ (Mpd_tag Artist, TU.bad_name_artist) ] () with
      | Error (_, _, _, error) -> TU.bad_branch error
      | Ok songs -> assert_equal 11 (List.length songs))

let test_music_database_searchadd _test_ctxt =
  let open Mpd.Music_database in
  TU.run_test_on_playlist (fun client ->
      match searchadd client [ (Mpd_tag Artist, TU.bad_name_artist) ] with
      | Error (_, _, _, error) -> TU.bad_branch error
      | Ok _ ->
          let len = queue_length client in
          assert_equal ~printer:(fun i -> string_of_int i) 11 len)

let test_music_database_searchaddpl _test_ctxt =
  let open Mpd.Music_database in
  TU.run_test_on_playlist (fun client ->
      let new_playlist = "searchaddpl_new_playlist" in
      let get_playlist_number () =
        match Mpd.Stored_playlists.listplaylists client with
        | Error message ->
            let () = TU.bad_branch message in
            -1
        | Ok playlists -> List.length playlists
      in
      match
        searchaddpl client new_playlist [ (Mpd_tag Artist, TU.bad_name_artist) ]
      with
      | Error (_, _, _, error) -> TU.bad_branch error
      | Ok _ ->
          let () = assert_equal 3 (get_playlist_number ()) in
          let () = ignore (Mpd.Stored_playlists.rm client new_playlist) in
          assert_equal 2 (get_playlist_number ()))

let test_music_database_count _test_ctxt =
  let open Mpd.Music_database in
  TU.run_test (fun client ->
      match count client [] ?group:(Some Artist) () with
      | Error message -> TU.bad_branch message
      | Ok counts -> assert_equal ~printer:string_of_int 1 (List.length counts))

let test_music_database_list_album _test_ctxt =
  let open Mpd.Music_database in
  TU.run_test (fun client ->
      match list client Album [ (Artist, TU.artist) ] with
      | Error message -> TU.bad_branch message
      | Ok elements ->
          let () =
            assert_equal ~printer:string_of_int 1 (List.length elements)
          in
          assert_equal ~printer TU.album (List.hd elements))

let test_music_database_list_title _test_ctxt =
  let open Mpd.Music_database in
  TU.run_test (fun client ->
      match list client Title [ (Artist, TU.artist); (Album, TU.album) ] with
      | Error message -> TU.bad_branch message
      | Ok elements ->
          let () =
            assert_equal ~printer:string_of_int 11 (List.length elements)
          in
          assert (TU.compare TU.songs elements))

let tests =
  "Queue and playlists tests"
  >::: [
         "test music database find" >:: test_music_database_find;
         "test music database findadd" >:: test_music_database_findadd;
         "test music database search" >:: test_music_database_search;
         "test music database searchadd" >:: test_music_database_searchadd;
         "test music database searchaddpl" >:: test_music_database_searchaddpl;
         "test music database count" >:: test_music_database_count;
         "test music database list album" >:: test_music_database_list_album;
         "test music database list title" >:: test_music_database_list_title;
       ]
