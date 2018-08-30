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
    | Ok _ ->
      let len = queue_length client in
      assert_equal ~printer:(fun i -> string_of_int i) 11 len
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
    | Ok _ ->
      let len = queue_length client in
      assert_equal ~printer:(fun i -> string_of_int i) 11 len
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

let test_music_database_list_album _test_ctxt =
  let open Mpd.Music_database in
  TU.run_test begin fun client ->
    let artist = "Bach JS" in
    (* TODO: improve, remove new line*)
    let album = "Die Kunst der Fuge, BWV 1080, for Piano\n" in
    match list client Album [(Artist, artist)] with
    | Error message -> assert_equal ~printer:(fun s -> s) "This should not have been reached " message
    | Ok elements ->
      let () = assert_equal ~printer:string_of_int 1 (List.length elements) in
      assert_equal ~printer album (List.hd elements)
  end

let songs =[
  "Contrapunctus 1";
  "Contrapunctus 10 a 4 alla Decima";
  "Contrapunctus 11 a 4";
  "Contrapunctus 2";
  "Contrapunctus 3";
  "Contrapunctus 4";
  "Contrapunctus 5";
  "Contrapunctus 6 a 4 in Stylo Francese";
  "Contrapunctus 7 a 4 per Augmentationem et Diminutionem";
  "Contrapunctus 8 a 3";
  "Contrapunctus 9 a 4 alla Duodecima\n";(* TODO: improve, remove new line*)
]

let rec compare l1 l2 = match l1, l2 with
  | [], [] -> true
  | [], _ -> false
  | _, [] -> false
  | h1 :: t1, h2 :: t2 -> h1 = h2 && compare t1 t2

let test_music_database_list_title _test_ctxt =
  let open Mpd.Music_database in
  TU.run_test begin fun client ->
    let artist = "Bach JS" in
    let album = "Die Kunst der Fuge, BWV 1080, for Piano\n" in
    match list client Title [(Artist, artist); (Album, album)] with
    | Error message -> assert_equal ~printer:(fun s -> s) "This should not have been reached " message
    | Ok elements ->
      let () = assert_equal ~printer:string_of_int 11 (List.length elements) in
      assert (compare songs elements)
  end

let tests =
  "Queue and playlists tests" >:::
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
