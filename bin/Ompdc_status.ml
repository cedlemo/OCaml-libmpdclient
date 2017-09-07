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

open Cmdliner
open Ompdc_common

(* let infos = ["volume", `Volume;
             "repeat", `Repeat;
             "random", `Random;
             "single", `Single;
             "consume", `Consume;
             "playlist", `Playlist;
             "playlistlength", `Playlistlength;
             "state", `State;
             "song", `Song;
             "songid", `Songid;
             "nextsong", `Nextsong;
             "nextsongid", `Nextsongid;
             "time", `Time;
             "elapsed", `Elapsed;
             "duration", `Duration;
             "bitrate", `Bitrate;
             "xfade", `Xfade;
             "mixrampdb", `Mixrampdb;
             "mixrampdelay", `Mixrampdelay;
             "audio", `Audio;
             "updating_db", `Updating_db;
             "error", `Error
]

let get_info common_opts name =
  let get_info_str = function
  | `Volume -> "volume"
  | `Repeat -> "repeat"
  | `Random -> "random"
  | `Single -> "single"
  | `Consume -> "consume"
  | `Playlist -> "playlist"
  | `Playlistlength -> "playlistlength"
  | `State -> "state"
  | `Song -> "song"
  | `Songid -> "songid"
  | `Nextsong -> "nextsong"
  | `Nextsongid -> "nextsongid"
  | `Time -> "time"
  | `Elapsed -> "elapsed"
  | `Duration -> "duration"
  | `Bitrate -> "bitrate"
  | `Xfade -> "xfade"
  | `Mixrampdb -> "mixrampdb"
  | `Mixrampdelay -> "mixrampdelay"
  | `Audio -> "audio"
  | `Updating_db -> "updating_db"
  | `Error -> "error"
  in
  let show_message host port name =
    let _name = match name with | None -> "no args" | Some s -> get_info_str s in
    let message = Printf.sprintf "%s:%d %s" host port _name in
    print_endline message
  in
  let {host; port} = common_opts in
  show_message host port name

let status_infos =
  let substitue = Printf.sprintf in
  let info_docs = List.map (fun (str, sym) ->
    match sym with
    | `Volume -> substitue "$(b,%s)" str
    | `Repeat -> substitue "$(b,%s)" str
    | `Random -> substitue "$(b,%s)" str
    | `Single -> substitue "$(b,%s)" str
    | `Consume -> substitue "$(b,%s)" str
    | `Playlist -> substitue "$(b,%s)" str
    | `Playlistlength -> substitue "$(b,%s)" str
    | `State -> substitue "$(b,%s)" str
    | `Song -> substitue "$(b,%s)" str
    | `Songid -> substitue "$(b,%s)" str
    | `Nextsong -> substitue "$(b,%s)" str
    | `Nextsongid -> substitue "$(b,%s)" str
    | `Time -> substitue "$(b,%s)" str
    | `Elapsed -> substitue "$(b,%s)" str
    | `Duration -> substitue "$(b,%s)" str
    | `Bitrate -> substitue "$(b,%s)" str
    | `Xfade -> substitue "$(b,%s)" str
    | `Mixrampdb -> substitue "$(b,%s)" str
    | `Mixrampdelay -> substitue "$(b,%s)" str
    | `Audio -> substitue "$(b,%s)" str
    | `Updating_db  -> substitue "$(b,%s)" str
    | `Error -> substitue "$(b,%s)" str
  ) infos in
  let doc = substitue "The information to extract. $(docv) must be one of: %s or nothing."
      (String.concat ", " info_docs)
  in
  let status_info = Arg.enum infos in
  Arg.(opt (some status_info) None & info [] ~doc ~docv:"INFO")
*)
type infos =
  | Volume
  | Repeat
  | Random
  | Single
  | Consume
  | Playlist
  | Playlistlength
  | State
  | Song
  | Songid
  | Nextsong
  | Nextsongid
  | Time
  | Elapsed
  | Duration
  | Bitrate
  | Xfade
  | Mixrampdb
  | Mixrampdelay
  | Audio
  | Updating_db
  | Error

  let get_info_str = function
  | Volume -> "volume"
  | Repeat -> "repeat"
  | Random -> "random"
  | Single -> "single"
  | Consume -> "consume"
  | Playlist -> "playlist"
  | Playlistlength -> "playlistlength"
  | State -> "state"
  | Song -> "song"
  | Songid -> "songid"
  | Nextsong -> "nextsong"
  | Nextsongid -> "nextsongid"
  | Time -> "time"
  | Elapsed -> "elapsed"
  | Duration -> "duration"
  | Bitrate -> "bitrate"
  | Xfade -> "xfade"
  | Mixrampdb -> "mixrampdb"
  | Mixrampdelay -> "mixrampdelay"
  | Audio -> "audio"
  | Updating_db -> "updating_db"
  | Error -> "error"

let get_info common_opts infos =
  let rec _parse = function
    | [] -> ()
    | i :: remain -> let _ = print_endline (get_info_str i) in
    _parse remain
  in
  _parse infos

let status_infos =
  let volume = Volume, Arg.info ["v"; "volume"; "vol"] in
  let repeat = Repeat, Arg.info ["r"; "repeat"] in
  let random = Random, Arg.info ["rand"; "random"] in
  let single = Single, Arg.info ["single"] in
  Arg.(value & vflag_all [Volume; Repeat; Random; Single] [volume; repeat; random; single])

let cmd =
  let doc = "Get all status information or only one specified in argument." in
  let man = [ `S Manpage.s_description;
              `P "Status commands in order to display Mpd server information.";
              `Blocks help_section
  ] in
  Term.(const get_info $ common_opts_t $ status_infos),
  Term.info "status" ~doc ~sdocs ~exits ~man
