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
open Mpd

let bad_branch () = assert_equal ~printer:(fun s -> s) "This should not " "have been reached"

let test_protocol_parse_response_simple_ok test_ctxt =
  match Protocol.parse_response "OK\n" with
  | Ok _ -> assert true
  | Error _ -> bad_branch ()

let test_protocol_parse_response_request_ok test_ctxt =
  match Protocol.parse_response "test: this is a complex\nresponse: request\nOK\n" with
  | Error _ -> bad_branch ()
  | Ok response -> match response with
    | None -> bad_branch ()
    | Some s -> let expected = "test: this is a complex\nresponse: request\n" in
      assert_equal ~printer:(fun s -> s) expected s

let test_protocol_parse_response_error_50 test_ctxt =
  match Protocol.parse_response "ACK [50@1] {play} error while playing\n" with
  | Ok _ -> bad_branch ()
  | Error (er_val, cmd_num, cmd, message) ->
      assert (er_val = No_exist && cmd_num = 1 && cmd = "play" && message = "error while playing")

let test_protocol_parse_response_error_1 test_ctxt =
  match Protocol.parse_response "ACK [1@12] {play} error while playing\n" with
  | Ok _ -> bad_branch ()
  | Error (er_val, cmd_num, cmd, message) ->
      assert (er_val = Not_list && cmd_num = 12 && cmd = "play" && message = "error while playing")

open Utils

let test_num_on_num_parse_simple_int test_ctxt =
  let simple_int = "3" in
  match Utils.num_on_num_parse simple_int with
  | Utils.Simple n -> assert_equal  3 n
                                        ~msg:"Simple int value"
                                        ~printer:string_of_int
  | _ -> assert_equal false true

let test_num_on_num_parse_num_on_num test_ctxt =
  let simple_int = "3/10" in
  match Utils.num_on_num_parse simple_int with
  | Utils.Num_on_num (a, b) -> assert_equal 3 a
                                        ~msg:"Simple int value"
                                        ~printer:string_of_int;
                                    assert_equal  10 b
                                        ~msg:"Simple int value"
                                        ~printer:string_of_int

  | _ -> assert_equal false true

let test_read_key_val test_ctxt =
  let key_val = "mykey: myvalue" in
  let {key = k; value = v} = Utils.read_key_val key_val in
  assert_equal "mykey" k;
  assert_equal "myvalue" v

let song = "file: Bjork-Volta/11 Earth Intruders (Mark Stent Exten.m4a
Last-Modified: 2009-09-21T14:25:52Z
Artist: Björk
Album: Volta
Title: Earth Intruders (Mark Stent Extended Mix)
Track: 11/13
Genre: Alternative
Date: 2007
Composer: Björk
Disc: 1/1
AlbumArtist: Björk
Time: 266
duration: 266.472
Pos: 10
Id: 11"

let test_song_parse test_ctxt =
  let song = Song.parse (Utils.split_lines song) in
  assert_equal "Björk" (Song.artist song);
  assert_equal "Volta" (Song.album song);
  assert_equal "Earth Intruders (Mark Stent Extended Mix)" (Song.title song);
  assert_equal "11/13" (Song.track song);
  assert_equal "Alternative" (Song.genre song);
  assert_equal "2007" (Song.date song);
  assert_equal "Björk" (Song.composer song);
  assert_equal "1/1" (Song.disc song);
  assert_equal "Björk" (Song.albumartist song);
  assert_equal "2009-09-21T14:25:52Z" (Song.last_modified song);
  assert_equal 266 (Song.time song);
  assert_equal 266.472 (Song.duration song);
  assert_equal 11 (Song.id song)

let playlist_info_list_data = "file: Wardruna-Runaljod-Yggdrasil-2013/01. Rotlaust Tre Fell_[plixid.com].mp3
file: jod/02. F.mp3
file: jod/03. N.mp3
file: jod/04. E.mp3
file: jod/05. A.mp3
file: jod/06. I.mp3
file: jod/07. I.mp3"

let test_list_playlist_response_parse test_ctxt =
  let paths = Utils.read_file_paths playlist_info_list_data in
  let second = List.nth paths 1 in
  assert_equal  ~printer:(fun s ->
      s)
    "jod/02. F.mp3" second

let listplaylists_data =
"playlist: zen
Last-Modified: 2014-12-02T10:15:57Z
playlist: rtl
Last-Modified: 2014-12-02T10:15:57Z
"

let test_listplaylists_response_parse test_ctxt =
  let playlist_names = Utils.read_list_playlists listplaylists_data in
  assert_equal ~printer:(fun s -> s) "zen rtl" (String.concat " " playlist_names)

let count_group_artist =
"Artist: jedi mind tricks
songs: 18
playtime: 4002
Artist: woven hand
songs: 11
playtime: 2491
"

let count_artist_woven_hand =
"songs: 11
playtime: 2491
"
let test_music_database_count_parse_group_artist test_ctxt =
  try
    let count = Utils.parse_count_response count_group_artist (Some "artist") in
    let _ = assert_equal 2 (List.length count) in
    let fst = List.nth count 0 in
    let scd = List.nth count 1 in
    let (songs, time, misc) = fst in
    let _ = assert_equal 18 songs in
    let _ = assert_equal 4002. time in
    let _ = assert_equal ~printer:(fun s -> s) "jedi mind tricks" misc in
    let (songs, time, misc) = scd in
    let _ = assert_equal 11 songs in
    let _ = assert_equal 2491. time in
    assert_equal ~printer:(fun s -> s) "woven hand" misc

  with Utils.EMusic_database message -> assert_equal ~printer:(fun s -> s) "" message

let test_music_database_count_parse_artist_woven_hand test_ctxt =
  try
    let count = Utils.parse_count_response count_artist_woven_hand None in
    let _ = assert_equal 1 (List.length count) in
    let fst = List.nth count 0 in
    let (songs, time, misc) = fst in
    let _ = assert_equal 11 songs in
    let _ = assert_equal 2491. time in
    assert_equal ~printer:(fun s -> s) "" misc

  with Utils.EMusic_database message -> assert_equal ~printer:(fun s -> s) "" message

let test_connection_lwt_mpd_banner_regex test_ctxt =
  let data = "OK MPD 1.23.4\n" in
  let pattern = "OK \\(\\(\n\\|.\\)*\\)\n" in
  match Str.string_match (Str.regexp pattern) data 0 with
  | false -> assert_equal ~message:"No banner found" true false
  | true -> let result = Str.matched_group 1 data in
      let _ = assert_equal ~printer:(fun s -> s) "MPD 1.23.4" result in
      assert_equal ~message:"Non used char"
                   ~printer:string_of_int
                   4 String.((length data) - (length result))

let tests =
    "Mpd responses parsing tests" >:::
      ["test protocol parse response simple OK" >::
        test_protocol_parse_response_simple_ok;
       "test protocol parse response request OK" >::
        test_protocol_parse_response_request_ok;
       "test protocol parse response error 50" >::
        test_protocol_parse_response_error_50;
       "test prototol parse response error 1" >::
        test_protocol_parse_response_error_1;
       "test Mpd.utils.num_on_num_parse simple int" >::
        test_num_on_num_parse_simple_int;
       "test Mpd.utils.num_on_num_parse num_on_num" >::
        test_num_on_num_parse_num_on_num;
       "test Mpd.utils.read_key_value" >:: test_read_key_val;
       "test Mpd.Song.parse" >:: test_song_parse;
       "test Utils.read_file_path" >:: test_list_playlist_response_parse;
       "test Mpd.utils.read_list_playlists" >::
        test_listplaylists_response_parse;
       "test Mpd.utils.parse_count_response" >::
        test_music_database_count_parse_group_artist;
       "test Mpd.utils.parse_count_response" >::
        test_music_database_count_parse_artist_woven_hand;
       "test connection lwt mpd banner regex" >::
        test_connection_lwt_mpd_banner_regex;
      ]
