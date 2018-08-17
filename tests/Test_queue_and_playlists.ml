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
  let client = TU.init_client () in
  let () = match Mpd.Stored_playlists.listplaylists client with
    | Error message ->
      assert_equal ~printer "This should not have been reached" message
    | Ok playlists ->
      let () = assert_equal ~printer:string_of_int 2 (List.length playlists) in
      let () = assert_equal ~printer "bach1" (List.hd playlists) in
      assert_equal ~printer "bach" (List.hd (List.tl playlists))
  in Mpd.Client.close client

let test_stored_playlists_load_playlist_and_clear _test_ctxt =
  let client = TU.init_client () in
  let () = begin match Mpd.Stored_playlists.load client "bach" () with
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
  in Mpd.Client.close client

(* let test_music_database_find _test_ctxt =
  let open Mpd.Music_database in
  let client = TU.init_client () in
  let _ = match find client [(Mpd_tag Artist, "Bach JS")] () with
    | Error (_, _, _, error) ->
      assert_equal ~printer "This should not have been reached " error
    | Ok songs -> assert_equal 11 (List.length songs)
  in Mpd.Client.close client

let test_music_database_findadd _test_ctxt =
  let open Music_database in
  let client = init_client () in
  let _ = match findadd client [(Mpd_tag Artist, "Bach JS")] with
    | Error (_, _, _, error) ->
      assert_equal ~printer "This should not have been reached " error
    | Ok _ -> let queue = Mpd.Queue.playlist client in
        let queue_length = match queue with
                           | Mpd.Queue.PlaylistError _ -> -1
                           | Mpd.Queue.Playlist p -> List.length p
        in
        assert_equal ~printer:(fun i -> string_of_int i) 11 queue_length

  in
  let _ = Mpd.Queue.clear client in
  Mpd.Client.close client

let test_music_database_search _test_ctxt =
  let open Music_database in
  let client = init_client () in
  let _ = match search client [(Mpd_tag Artist, "bACH js")] () with
    | Error (_, _, _, error) ->
      assert_equal ~printer "This should not have been reached " error
    | Ok songs -> assert_equal 11 (List.length songs)
  in
  let _ = Mpd.Queue.clear client in
  Mpd.Client.close client

let test_music_database_searchadd _test_ctxt =
  let open Music_database in
  let client = init_client () in
  let _ = match searchadd client [(Mpd_tag Artist, "bACH js")] with
    | Error (_, _, _, error) ->
      assert_equal ~printer "This should not have been reached " error
    | Ok _ -> let queue = Mpd.Queue.playlist client in
        let queue_length = match queue with
                           | Mpd.Queue.PlaylistError _ -> -1
                           | Mpd.Queue.Playlist p -> List.length p
        in
        assert_equal ~printer:(fun i -> string_of_int i) 11 queue_length

  in
  let _ = Mpd.Queue.clear client in
  Mpd.Client.close client

let test_music_database_searchaddpl _test_ctxt =
  let open Music_database in
  let client = init_client () in
  let new_playlist = "searchaddpl_new_playlist" in
  let _ =
    match searchaddpl client new_playlist [(Mpd_tag Artist, "bACH js")] with
    | Error (_, _, _, error) ->
      assert_equal ~printer "This should not have been reached " error
    | Ok _ -> match Mpd.Stored_playlists.listplaylists client with
      | None ->
        assert_equal ~printer "This should not " "have been reached"
        | Some playlists -> let _ = assert_equal 3 (List.length playlists) in
          assert_bool "searchaddpl test: new playlistname not found" (List.mem new_playlist playlists)
  in Mpd.Client.close client

let test_music_database_count _test_ctxt =
  let open Music_database in
  let client = init_client () in
  match count client [] ?group:(Some Artist) () with
  | Error message -> assert_equal ~printer:(fun s -> s) "This should not have been reached " message
  | Ok counts -> assert_equal ~printer:(fun s -> string_of_int s) 1 (List.length counts)
*)
let tests =
  "Queue and playlists tests" >:::
    [
      "test stored playlists listplaylists" >:: test_stored_playlists_listplaylists;
      "test stored playlists load playlist and clear" >:: test_stored_playlists_load_playlist_and_clear;
      (*
       "test music database find" >:: test_music_database_find;
      "test music database findadd" >:: test_music_database_findadd;
      "test music database search" >:: test_music_database_search;
      "test music database searchadd" >:: test_music_database_searchadd;
      "test music database searchaddpl" >:: test_music_database_searchaddpl;
         "test music database count" >:: test_music_database_count;
      "test queue clear" >:: test_queue_clear;
      *)
    ]
