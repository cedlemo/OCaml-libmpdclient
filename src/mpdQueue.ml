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

(** Module for Mpd current playlist manipulation. *)

open Mpd_utils

type p =
  | PlaylistError of string | Playlist of Song.s list

(** Adds the file URI to the playlist (directories add recursively). URI can also be a single file. *)
let add client uri =
  Mpd.Client.send client uri

(** Adds a song to the playlist (non-recursive) and returns the song id.
  URI is always a single file or URL. For example:
*)
let addid client uri position =
  let cmd = String.concat " " ["addid"; uri; string_of_int position] in
  let response = Mpd.Client.send client cmd in
  match response with
  |Protocol.Ok (song_id) -> let lines = Mpd_utils.split_lines song_id in
  let rec parse lines =
    match lines with
      | [] -> -1
      | line :: remain -> let { key = k; value = v} = Mpd_utils.read_key_val line in
      if (k = "Id") then int_of_string v
                          else parse remain
      in parse lines
      |Protocol.Error (_) -> -1

(** Clears the current playlist. *)
let clear client =
  Mpd.Client.send client "clear"

(** Deletes a song or a set of songs from the playlist. The song or the range
 of songs are identified by the position in the playlist. *)
let delete client position ?position_end () =
  let cmd = match position_end with
  |None -> String.concat " " ["delete"; string_of_int position]
  |Some pos_end -> String.concat "" ["delete ";
                                     string_of_int position;
                                     ":";
                                     string_of_int pos_end]
in Mpd.Client.send client cmd

(** Deletes the song SONGID from the playlist. *)
let deleteid client id =
  Mpd.Client.send client (String.concat " " ["deleteid"; string_of_int id])

(** Moves the song at FROM or range of songs at START:END to TO in
 the playlist. *)
let move client position_from ?position_end position_to () =
  let cmd = match position_end with
  |None -> String.concat " " ["move";
                              string_of_int position_from;
                              string_of_int position_to]
  |Some pos_end -> String.concat "" ["move ";
                                     string_of_int position_from;
                                     ":";
                                     string_of_int pos_end;
                                     " ";
                                     string_of_int position_to]
in Mpd.Client.send client cmd

(** Moves the song with FROM (songid) to TO (playlist index) in the playlist.
 If TO is negative, it is relative to the current song in the playlist
 (if there is one). *)
let moveid client id position_to =
  Mpd.Client.send client (String.concat " " ["moveid";
                                            string_of_int id;
                                            string_of_int position_to])

let get_song_id song =
  let pattern = "\\([0-9]+\\):file:.*" in
  let found = Str.string_match (Str.regexp pattern) song 0 in
  if found then Str.matched_group 1 song
  else "none"

let rec _build_songs_list client songs l =
  match songs with
  | [] -> Playlist (List.rev l)
  | h :: q -> let song_infos_request = "playlistinfo " ^ (get_song_id h) in
  match Mpd.Client.send client song_infos_request with
  | Protocol.Error (ack_val, ack_cmd_num, ack_cmd, ack_message)-> PlaylistError (ack_message)
  | Protocol.Ok (song_infos) -> let song = Song.parse (Mpd_utils.split_lines song_infos) in
   _build_songs_list client q (song :: l)

(** Get a list of Song.s that represents all the songs in the current playlist. *)
let playlist client =
  match Mpd.Client.send client "playlist" with
  | Protocol.Error (ack_val, ack_cmd_num, ack_cmd, ack_message)-> PlaylistError (ack_message)
  | Protocol.Ok (response) -> let songs = Mpd_utils.split_lines response in
  _build_songs_list client songs []

(** Get a list with the Song.s of the song id in the playlist *)
let playlistid client id =
  let request = "playlistid " ^ (string_of_int id) in
  match Mpd.Client.send client request with
  | Protocol.Error (ack_val, ack_cmd_num, ack_cmd, ack_message)-> PlaylistError (ack_message)
  | Protocol.Ok (response) -> let song = Song.parse (Mpd_utils.split_lines response) in
  Playlist (song::[])
