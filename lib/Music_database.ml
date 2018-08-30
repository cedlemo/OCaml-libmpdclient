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

type tags =
  | Unknown
  | Artist
  | Album
  | Album_artist
  | Title
  | Track
  | Name
  | Genre
  | Date
  | Composer
  | Performer
  | Comment
  | Disc
  | Musicbrainz_artistid
  | Musicbrainz_albumid
  | Musicbrainz_albumartistid
  | Musicbrainz_trackid
  | Musicbrainz_releasetrackid
  | Original_date
  | Artist_sort
  | Album_artist_sort
  | Album_sort
  | Count

let tag_to_string = function
  | Unknown -> "unknown"
  | Artist -> "artist"
  | Album -> "album"
  | Album_artist -> "album_artist"
  | Title -> "title"
  | Track -> "track"
  | Name -> "name"
  | Genre -> "genre"
  | Date -> "date"
  | Composer -> "composer"
  | Performer -> "performer"
  | Comment -> "comment"
  | Disc -> "disc"
  | Musicbrainz_artistid -> "musicbrainz_artistid"
  | Musicbrainz_albumid -> "musicbrainz_albumid"
  | Musicbrainz_albumartistid -> "musicbrainz_albumartistid"
  | Musicbrainz_trackid -> "musicbrainz_trackid"
  | Musicbrainz_releasetrackid -> "musicbrainz_releasetrackid"
  | Original_date -> "original_date"
  | Artist_sort -> "artist_sort"
  | Album_artist_sort -> "album_artist_sort"
  | Album_sort -> "album_sort"
  | Count -> "count"

(* TODO: check for warning :
   constraints are not satisfied in this type. Type tags should be an instance of
*)
type search_tags = Any | File | Base | Modified_since | Mpd_tag of tags

let search_tag_to_string = function
  | Any -> "any"
  | File -> "file"
  | Base -> "base"
  | Modified_since -> "modified-since"
  | Mpd_tag t -> tag_to_string t

let build_tag_parameter printer tags =
  let tag_and_param_to_string (t, p) =
    Printf.sprintf "%s \"%s\"" (printer t) p
  in
  List.map tag_and_param_to_string tags
  |> String.concat " "

let search_find_wrapper cmd_name client what_list ?sort ?window () =
  let what = build_tag_parameter search_tag_to_string what_list in
  let sort = match sort with
    | None -> ""
    | Some tag -> " sort " ^ (tag_to_string tag)
  in
  let window = match window with
    | None -> ""
    | Some (start, stop) ->
      Printf.sprintf " window %d:%d" start stop
  in
  let cmd = Printf.sprintf "%s %s%s%s" cmd_name what sort window in
  match Client.send_request client cmd with
  | Error err -> Error err
  | Ok response -> match response with
    | None -> Ok []
    | Some r ->
      let songs =
        Str.split (Str.regexp_string "file:") r
        |> let build_song s =
             Utils.split_lines s |> Song.parse
        in List.map build_song
      in Ok songs

let find = search_find_wrapper "find"

let search = search_find_wrapper "search"

let search_find_add_wrapper cmd_name client what_list =
  let what = build_tag_parameter search_tag_to_string what_list in
  let cmd = Printf.sprintf "%s %s" cmd_name what in
  Client.send_command client cmd

let findadd = search_find_add_wrapper "findadd"

let searchadd = search_find_add_wrapper "searchadd"

let searchaddpl client playlist_name what_list =
  search_find_add_wrapper ("searchaddpl " ^ playlist_name) client what_list

type song_count = { songs: int; playtime: float; misc: string }

let count client what_list ?group () =
  let what = build_tag_parameter tag_to_string what_list in
  let group = match group with
    | None -> None
    | Some tag -> Some (tag_to_string tag)
  in
  let cmd = Printf.sprintf "count %s %s" what (match group with None -> "" | Some s -> " group " ^ s) in
  match Client.send_request client cmd with
  | Error (_, _, _, message) -> Error message
  | Ok response -> match response with
    | None -> Ok []
    | Some r ->
      let result = Utils.parse_count_response r group in
      let tuple_to_song_count (songs, playtime, misc) = {songs; playtime; misc}
      in
      let song_counts = List.map tuple_to_song_count result in
      Ok song_counts

let list client tag tag_list =
  let filter = tag_to_string tag |> String.capitalize_ascii in
  let tags = build_tag_parameter tag_to_string tag_list in
  let cmd = Printf.sprintf "list %s %s" filter tags in
  match Client.send_request client cmd with
  | Error (_, _, _, message) -> Error message
  | Ok response -> match response with
    | None -> Ok []
    | Some r -> let split_pattern = Printf.sprintf "\\(\n\\)*%s: " filter in
      let l = match Str.split (Str.regexp split_pattern) r with
        | [] -> []
        | h :: t -> if h = "" then t else (h :: t)
      in Ok l

let update client uri =
  let cmd = match uri with
    | None -> "update"
    | Some uri' -> "update " ^ uri'
  in Client.send_request client cmd

let rescan client uri =
  let cmd = match uri with
    | None -> "rescan"
    | Some uri' -> "rescan " ^ uri'
  in Client.send_command client cmd
