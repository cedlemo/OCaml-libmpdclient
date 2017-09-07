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
  let consume = Consume, Arg.info ["c"; "consume"] in
  let playlist = Playlist, Arg.info ["plist"; "playlist"] in
  let playlistlength = Playlistlength, Arg.info ["plistl"; "playlistlength"] in
  let state = State, Arg.info ["st"; "state"] in
  let song = Song, Arg.info ["so"; "song"] in
  let songid = Songid, Arg.info ["soid"; "songid"] in
  let nextsong = Nextsong, Arg.info ["nso"; "nextsong"] in
  let nextsongid = Nextsongid, Arg.info ["nsoid"; "nextsongid"] in
  let time = Time, Arg.info ["t"; "time"] in
  let elapsed = Elapsed, Arg.info ["e"; "elapsed"] in
  let duration = Duration, Arg.info ["d"; "duration"] in
  let bitrate = Bitrate, Arg.info ["b"; "bitrate"] in
  let xfade = Xfade, Arg.info ["x"; "xfade"] in
  let mixrampdb = Mixrampdb, Arg.info ["mixdb"; "mixrampdb"] in
  let mixrampdelay = Mixrampdelay, Arg.info ["mixdelay"; "mixrampdelay"] in
  let audio = Audio, Arg.info ["a"; "audio"] in
  let updating_db = Updating_db, Arg.info ["u"; "Updating_db"] in
  let error = Error, Arg.info ["err"; "error"] in
  Arg.(value & vflag_all [Volume; Repeat; Random; Single; Consume; Playlist;
                          Playlistlength; State; Song; Songid; Nextsong;
                          Nextsongid; Time; Elapsed; Duration; Bitrate; Xfade;
                          Mixrampdb; Mixrampdelay; Audio; Updating_db; Error]
                         [volume; repeat; random; single; consume; playlist;
                          playlistlength; state; song; songid; nextsong;
                          nextsongid; time; elapsed; duration; bitrate; xfade;
                          mixrampdb; mixrampdelay; audio; updating_db; error])

let cmd =
  let doc = "Get all status information or only one specified in argument." in
  let man = [ `S Manpage.s_description;
              `P "Status commands in order to display Mpd server information.";
              `Blocks help_section
  ] in
  Term.(const get_info $ common_opts_t $ status_infos),
  Term.info "status" ~doc ~sdocs ~exits ~man
