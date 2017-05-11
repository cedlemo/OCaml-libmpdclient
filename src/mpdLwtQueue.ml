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

open Mpd_utils
open Lwt.Infix

type p =
  | PlaylistError of string
  | Playlist of Song.s list

let add client uri =
  Mpd.LwtClient.send client uri

let addid client uri position =
  let cmd = String.concat " " ["addid"; uri; string_of_int position] in
  Mpd.LwtClient.send client cmd
  >>= function
  | Protocol.Ok (song_id) -> let lines = Mpd_utils.split_lines song_id in
    let rec parse lines =
      match lines with
      | [] -> Lwt.return (-1)
      | line :: remain -> let { key = k; value = v} = Mpd_utils.read_key_val line in
        if (k = "Id") then Lwt.return (int_of_string v)
        else Lwt.return remain
          >>= fun lines ->
          parse lines
    in parse lines
  | Protocol.Error (_) -> Lwt.return (-1)

let clear client =
  Mpd.LwtClient.send client "clear"

let delete client position ?position_end () =
  let cmd = match position_end with
  |None -> String.concat " " ["delete"; string_of_int position]
  |Some pos_end -> String.concat "" ["delete ";
                                     string_of_int position;
                                     ":";
                                     string_of_int pos_end]
  in Mpd.LwtClient.send client cmd

let deleteid client id =
  Mpd.LwtClient.send client (String.concat " " ["deleteid"; string_of_int id])

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
  in Mpd.LwtClient.send client cmd

let moveid client id position_to =
  Mpd.LwtClient.send client (String.concat " " ["moveid";
                                                string_of_int id;
                                                string_of_int position_to])

let get_song_id song =
  let pattern = "\\([0-9]+\\):file:.*" in
  let found = Str.string_match (Str.regexp pattern) song 0 in
  if found then Str.matched_group 1 song
  else "none"

let rec _build_songs_list client songs l =
  match songs with
  | [] -> let playlist = Playlist (List.rev l) in Lwt.return  playlist
  | h :: q -> let song_infos_request = "playlistinfo " ^ (get_song_id h) in
    Mpd.LwtClient.send client song_infos_request
    >>= function
    | Protocol.Error (_, _, _, ack_message)->
      Lwt.return (PlaylistError (ack_message))
    | Protocol.Ok (song_infos) ->
      let song = Song.parse (Mpd_utils.split_lines song_infos) in
      _build_songs_list client q (song :: l)

let playlist client =
  Mpd.LwtClient.send client "playlist"
  >>= function
  | Protocol.Error (_, _, _, ack_message)->
    Lwt.return (PlaylistError (ack_message))
  | Protocol.Ok (response) ->
    let songs = Mpd_utils.split_lines response in
    _build_songs_list client songs []

let playlistid client id =
  let request = "playlistid " ^ (string_of_int id) in
  Mpd.LwtClient.send client request
  >>= function
  | Protocol.Error (_, _, _, ack_message)->
    Lwt.return (PlaylistError (ack_message))
  | Protocol.Ok (response) ->
    let song = Song.parse (Mpd_utils.split_lines response) in
    Lwt.return (Playlist (song::[]))

let playlistfind client tag needle =
  let request = String.concat " " ["playlistfind"; tag; needle] in
  Mpd.LwtClient.send client request
  >>= function
  | Protocol.Error (_, _, _, ack_message)->
    Lwt.return (PlaylistError (ack_message))
  | Protocol.Ok (response) ->
    let songs = Mpd_utils.split_lines response in
    _build_songs_list client songs []

let playlistsearch client tag needle =
  let request = String.concat " " ["playlistsearch"; tag; needle] in
  Mpd.LwtClient.send client request
  >>= function
  | Protocol.Error (_, _, _, ack_message)->
    Lwt.return (PlaylistError (ack_message))
  | Protocol.Ok (response) ->
    let songs = Mpd_utils.split_lines response in
    _build_songs_list client songs []

let swap client pos1 pos2 =
  Mpd.LwtClient.send client (String.concat " " ["swap";
                                                string_of_int pos1;
                                                string_of_int pos2])

let shuffle client ?range () =
  let request = match range with
    |None -> "shuffle"
    |Some (s, e) -> let r = String.concat ":" [string_of_int s; string_of_int e] in
      String.concat " " ["shuffle"; r]
  in Mpd.LwtClient.send client request

let prio client priority ?range () =
  let priority' = string_of_int ( if priority > 255 then 255
                                  else if priority < 0 then 0
                                  else priority)
  in
  let request = match range with
    | None -> "prio " ^ priority'
    | Some (s, e) -> let r = String.concat ":" [string_of_int s; string_of_int e] in
      String.concat " " ["prio"; r]
  in Mpd.LwtClient.send client request

let prioid client priority ids =
  let priority' = string_of_int ( if priority > 255 then 255
                                  else if priority < 0 then 0
                                  else priority)
  in
  let ids' = String.concat " " (List.map (fun i -> string_of_int i) ids) in
  let request = String.concat " " ["prioid"; priority'; ids'] in
  Mpd.LwtClient.send client request

let swapid client id1 id2 =
  let request = String.concat " " ["swapid";
                                   string_of_int id1;
                                   string_of_int id2 ] in
  Mpd.LwtClient.send client request

let rangeid client id ?range () =
  let id' = string_of_int id in
  let cmd = "rangeid" in
  let request = match range with
    | None -> String.concat " " [cmd; id'; ":"]
    | Some (s, e) ->
      let r = String.concat ":" [string_of_float s; string_of_float e] in
      String.concat " " [cmd; r]
  in
  Mpd.LwtClient.send client request
