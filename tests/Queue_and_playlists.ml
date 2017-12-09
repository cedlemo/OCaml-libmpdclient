(*
 * Copyright 2017 Cedric LE MOIGNE, cedlemo@gmx.com
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

let host = "127.0.0.1"
let port = 6600

let init_client () =
  let connection = Mpd.Connection.initialize host port in
  let client = Mpd.Client.initialize connection in
  let _ = Mpd.Music_database.update client in
  client

let test_stored_playlists_listplaylists test_ctxt =
  let client = init_client () in
  match Mpd.Stored_playlists.listplaylists client with
  | None -> assert_equal ~printer:(fun s -> s) "This should not " "have been reached"
  | Some playlists -> let _ = assert_equal 2 (List.length playlists) in
    let _ = assert_equal ~printer:(fun s -> s) "bach1" (List.hd playlists) in
    assert_equal ~printer:(fun s -> s) "bach" (List.hd (List.tl playlists))

let test_stored_playlists_load_playlist test_ctxt =
  let client = init_client () in
  match Mpd.Stored_playlists.load client "bach" () with
  | Error (_, _, _, message) -> assert_equal ~printer:(fun s -> s) "This should not have been reached " message
  | Ok _ -> let queue = Mpd.Queue.playlist client in
    let queue_length = match queue with
                       | Mpd.Queue.PlaylistError _ -> -1
                       | Mpd.Queue.Playlist p -> List.length p
    in
    assert_equal ~printer:(fun i -> string_of_int i) 11 queue_length

let tests =
  "Queue and playlists tests" >:::
    [
      "test stored playlists listplaylists" >:: test_stored_playlists_listplaylists;
      "test stored playlists load playlist" >:: test_stored_playlists_load_playlist;
    ]
