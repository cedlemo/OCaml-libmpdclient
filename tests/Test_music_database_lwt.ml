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

open Lwt.Infix
open OUnit2
module TU = Test_utils

let printer = TU.printer
let queue_length_lwt = TU.queue_length_lwt
let bad_branch = TU.bad_branch

let test_music_database_find _test_ctxt =
  let open Mpd.Music_database_lwt in
  TU.run_test_on_playlist_lwt begin fun client ->
    find client [(Mpd_tag Artist, TU.artist)] ()
    >>= fun response ->
    let () = match response with
      | Error (_, _, _, error) -> bad_branch error
      | Ok songs -> assert_equal 11 (List.length songs)
    in
    Lwt.return_unit
  end

let test_music_database_findadd _test_ctxt =
  let open Mpd.Music_database_lwt in
  TU.run_test_on_playlist_lwt begin fun client ->
    findadd client [(Mpd_tag Artist, TU.artist)]
    >>= fun response ->
    TU.queue_length_lwt client
    >>= fun len ->
    let () = match response with
      | Error (_, _, _, error) -> bad_branch error
      | Ok _ ->
        assert_equal ~printer:string_of_int 11 len
    in
    Lwt.return_unit
  end

let test_music_database_search _test_ctxt =
  let open Mpd.Music_database_lwt in
  TU.run_test_lwt begin fun client ->
    search client [(Mpd_tag Artist, TU.bad_name_artist)] ()
    >>= fun response ->
    let () = match response with
      | Error (_, _, _, error) -> bad_branch error
      | Ok songs -> assert_equal 11 (List.length songs)
    in
    Lwt.return_unit
  end

let test_music_database_searchadd _test_ctxt =
  let open Mpd.Music_database_lwt in
  TU.run_test_on_playlist_lwt begin fun client ->
    searchadd client [(Mpd_tag Artist, TU.bad_name_artist)]
    >>= fun response ->
    queue_length_lwt client
    >>= fun len ->
    let () = match response with
      | Error (_, _, _, error) -> bad_branch error
      | Ok _ ->
        assert_equal ~printer:string_of_int 11 len
    in
    Lwt.return_unit
  end

let test_music_database_searchaddpl _test_ctxt =
  let open Mpd.Music_database_lwt in
  TU.run_test_on_playlist_lwt begin fun client ->
    let new_playlist = "searchaddpl_new_playlist" in
    let get_playlist_number () =
      Mpd.Stored_playlists_lwt.listplaylists client
      >>= function
      | Error message -> let () = bad_branch message in Lwt.return (-1)
      | Ok playlists -> let len = List.length playlists in Lwt.return len
    in
    searchaddpl client new_playlist [(Mpd_tag Artist, TU.bad_name_artist)]
    >>= function
    | Error (_, _, _, error) -> let () = bad_branch error in Lwt.return_unit
    | Ok _ ->
      get_playlist_number ()
      >>= fun len ->
      let () = assert_equal 3 len in
      Mpd.Stored_playlists_lwt.rm client new_playlist
      >>= fun _ ->
      get_playlist_number ()
      >>= fun len' ->
      let () = assert_equal 2  len' in
      Lwt.return_unit
  end

let test_music_database_count _test_ctxt =
  let open Mpd.Music_database_lwt in
  TU.run_test_lwt begin fun client ->
    count client [] ?group:(Some Artist) ()
    >>= fun response ->
    let () = match response with
      | Error message -> bad_branch message
      | Ok counts -> assert_equal ~printer:string_of_int 1 (List.length counts)
    in
    Lwt.return_unit
  end

let test_music_database_list_album _test_ctxt =
  let open Mpd in
  TU.run_test_lwt begin fun client ->
    Music_database_lwt.list client Album [(Artist, TU.artist)]
    >>= fun response ->
    let () = match response with
      | Error message -> bad_branch message
      | Ok elements ->
        let () = assert_equal ~printer:string_of_int 1 (List.length elements) in
        assert_equal ~printer TU.album (List.hd elements)
    in Lwt.return_nil
  end

let test_music_database_list_title _test_ctxt =
  let open Mpd in
  TU.run_test_lwt begin fun client ->
    Music_database_lwt.list client Title [(Artist, TU.artist); (Album, TU.album)]
    >>= fun response ->
    let () = match response with
      | Error message -> bad_branch message
      | Ok elements ->
        let () = assert_equal ~printer:string_of_int 11 (List.length elements) in
        assert (TU.compare TU.songs elements)
    in Lwt.return_nil
  end

let tests =
  "Queue and playlists lwt tests" >:::
  [
    "test music database find" >:: test_music_database_find;
    "test music database findadd" >:: test_music_database_findadd;
    "test music database search" >:: test_music_database_search;
    "test music database searchadd" >:: test_music_database_searchadd;
    "test music database searchaddpl" >:: test_music_database_searchaddpl;
    "test music database count" >:: test_music_database_count;
    "test music database list album" >:: test_music_database_list_album;
    "test music database list title" >:: test_music_database_list_title;
  ]
