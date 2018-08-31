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
open Tags

let search_find_wrapper cmd_name client what_list ?sort ?window () =
  let what =
    List.map (fun (tag, param) -> Printf.sprintf "%s \"%s\"" (search_tag_to_string tag) param) what_list
    |> String.concat " "
  in
  let sort = match sort with
    | None -> ""
    | Some tag -> " sort " ^ (tag_to_string tag)
  in
  let window = match window with
    | None -> ""
    | Some (start, stop) -> Printf.sprintf " window %s:%s" (string_of_int start) (string_of_int stop)
  in
  let cmd = Printf.sprintf "%s %s%s%s" cmd_name what sort window in
  Client_lwt.request client cmd
  >>= function
    | Error err -> Lwt.return (Error err)
    | Ok response -> match response with
        | None -> Lwt.return (Ok [])
        | Some r ->
           let songs = Str.split (Str.regexp_string "file:") r
           |> List.map (fun s -> Str.split (Str.regexp_string "\n") s |> Song.parse)
           in Lwt.return (Ok songs)

let find = search_find_wrapper "find"

let search = search_find_wrapper "search"

let search_find_add_wrapper cmd_name client what_list =
  let what =
    List.map (fun (tag, param) -> Printf.sprintf "%s \"%s\"" (search_tag_to_string tag) param) what_list
    |> String.concat " "
  in
  let cmd = Printf.sprintf "%s %s" cmd_name what in
  Client_lwt.request client cmd

let findadd = search_find_add_wrapper "findadd"

let searchadd = search_find_add_wrapper "searchadd"

let searchaddpl client playlist_name what_list =
  search_find_add_wrapper ("searchaddpl " ^ playlist_name) client what_list

type song_count = { songs: int; playtime: float; misc: string }

let count client what_list ?group () =
  let what =
    List.map (fun (tag, param) -> Printf.sprintf "%s \"%s\"" (tag_to_string tag) param) what_list
    |> String.concat " "
  in
  let group = match group with
    | None -> None
    | Some tag -> Some (tag_to_string tag)
  in
  let cmd = Printf.sprintf "count %s %s" what (match group with None -> "" | Some s -> "group " ^ s) in
  Client_lwt.request client cmd
  >>= function
    | Error (_, _, _, message) -> Lwt.return (Error message)
    | Ok response -> match response with
      | None -> Lwt.return (Ok [])
      | Some r ->
        let result = Utils.parse_count_response r group in
        let song_counts = List.map (fun (songs, playtime, misc) -> {songs; playtime; misc}) result in
        Lwt.return (Ok song_counts)

let list client tag tag_list =
  let filter = tag_to_string tag |> String.capitalize_ascii in
  let tags = List.map (fun (t, p) ->
                       Printf.sprintf "%s \"%s\"" (tag_to_string t) p) tag_list
            |> String.concat " "
  in
  let cmd = Printf.sprintf "list %s %s" filter tags in
  Client_lwt.request client cmd
  >>= function
  | Error (_, _, _, message) -> Lwt.return (Error message)
  | Ok response -> match response with
      | None -> Lwt.return (Ok [])
      | Some r -> let split_pattern = Printf.sprintf "\\(\n\\)*%s: " filter in
      let l = match Str.split (Str.regexp split_pattern) r with
        | [] -> []
        | h :: t ->
            if h = "" then t
            else let h' = Utils.remove_trailing_new_line h in (h' :: t)
      in Lwt.return (Ok l)


let update client uri =
  let cmd = match uri with
  | None -> "update"
  | Some uri' -> "update " ^ uri'
  in Client_lwt.request client cmd

let rescan client uri =
  let cmd = match uri with
  | None -> "rescan"
  | Some uri' -> "rescan " ^ uri'
  in Client_lwt.send client cmd
