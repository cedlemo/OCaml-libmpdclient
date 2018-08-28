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

let test_music_database_find _test_ctxt =
  let open Mpd.Music_database_lwt in
  TU.run_test_on_playlist_lwt begin fun client ->
    find client [(Mpd_tag Artist, "Bach JS")] ()
    >>= fun response ->
    let () = match response with
      | Error (_, _, _, error) ->
        assert_equal ~printer "This should not have been reached " error
      | Ok songs -> assert_equal 11 (List.length songs)
    in
    Lwt.return_unit
  end

let test_music_database_findadd _test_ctxt =
  let open Mpd.Music_database_lwt in
  TU.run_test_on_playlist_lwt begin fun client ->
    findadd client [(Mpd_tag Artist, "Bach JS")]
    >>= fun response ->
    TU.queue_length_lwt client
    >>= fun len ->
    let () = match response with
      | Error (_, _, _, error) ->
        assert_equal ~printer "This should not have been reached " error
      | Ok _ ->
        assert_equal ~printer:(fun i -> string_of_int i) 11 len
    in
    Lwt.return_unit
  end

let test_music_database_search _test_ctxt =
  let open Mpd.Music_database_lwt in
  TU.run_test_lwt begin fun client ->
    search client [(Mpd_tag Artist, "bACH js")] ()
    >>= fun response ->
    let () = match response with
      | Error (_, _, _, error) ->
        assert_equal ~printer "This should not have been reached " error
      | Ok songs -> assert_equal 11 (List.length songs)
    in
    Lwt.return_unit
  end

let test_music_database_searchadd _test_ctxt =
  let open Mpd.Music_database_lwt in
  TU.run_test_on_playlist_lwt begin fun client ->
    searchadd client [(Mpd_tag Artist, "bACH js")]
    >>= fun response ->
    queue_length_lwt client
    >>= fun len ->
    let () = match response with
      | Error (_, _, _, error) ->
        assert_equal ~printer "This should not have been reached " error
      | Ok _ ->
        assert_equal ~printer:(fun i -> string_of_int i) 11 len
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
      | Error message ->
        let () = assert_equal ~printer "This should not have been reached " message in
        Lwt.return (-1)
      | Ok playlists -> let len = List.length playlists in Lwt.return len
    in
    searchaddpl client new_playlist [(Mpd_tag Artist, "bACH js")]
    >>= function
    | Error (_, _, _, error) ->
      let () = assert_equal ~printer "This should not have been reached " error
      in Lwt.return_unit
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

let tests =
  "Queue and playlists lwt tests" >:::
  [
    "test music database find" >:: test_music_database_find;
    "test music database findadd" >:: test_music_database_findadd;
    "test music database search" >:: test_music_database_search;
    "test music database searchadd" >:: test_music_database_searchadd;
    "test music database searchaddpl" >:: test_music_database_searchaddpl;
  ]
