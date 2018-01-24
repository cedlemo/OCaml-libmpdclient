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

let test_simple_ok test_ctxt =
  match Protocol.parse_response "OK\n" with
  | Ok _ -> assert true
  | Error _ -> bad_branch ()

let test_request_ok test_ctxt =
  match Protocol.parse_response "test: this is a complex\nresponse: request\nOK\n" with
  | Error _ -> bad_branch ()
  | Ok response -> match response with
    | None -> bad_branch ()
    | Some s -> let expected = "test: this is a complex\nresponse: request\n" in
      assert_equal ~printer:(fun s -> s) expected s

let test_error_50 test_ctxt =
  match Protocol.parse_response "ACK [50@1] {play} error while playing\n" with
  | Ok _ -> bad_branch ()
  | Error (er_val, cmd_num, cmd, message) ->
      assert (er_val = No_exist && cmd_num = 1 && cmd = "play" && message = "error while playing")

let test_error_1 test_ctxt =
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

let mpd_responses_parsing_tests =
    "Mpd responses parsing tests" >:::
      ["test simple OK" >:: test_simple_ok;
       "test request OK" >:: test_request_ok;
       "test error 50" >:: test_error_50;
       "test error 1" >:: test_error_1;
       "test Mpd.utils.num_on_num_parse simple int" >:: test_num_on_num_parse_simple_int;
       "test Mpd.utils.num_on_num_parse num_on_num" >:: test_num_on_num_parse_num_on_num;
       "test Mpd.utils.read_key_value" >:: test_read_key_val;
       "test Mpd.Song.parse" >:: test_song_parse;
       "test Utils.read_file_path" >:: test_list_playlist_response_parse;
       "test Mpd.utils.read_list_playlists" >:: test_listplaylists_response_parse
      ]

  let () =
    run_test_tt_main mpd_responses_parsing_tests
