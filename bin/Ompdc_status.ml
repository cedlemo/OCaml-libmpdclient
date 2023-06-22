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


let get_mpd_status_info status = function
  | Volume -> ["volume:"; string_of_int @@ Mpd.Status.volume status]
  | Repeat -> ["repeat:"; string_of_bool @@ Mpd.Status.repeat status]
  | Random -> ["random:"; string_of_bool @@ Mpd.Status.random status]
  | Single -> ["single:"; string_of_bool @@ Mpd.Status.single status]
  | Consume -> ["consume:"; string_of_bool @@ Mpd.Status.consume status]
  | Playlist ->["playlist:"; string_of_int @@ Mpd.Status.playlist status]
  | Playlistlength -> ["playlistlength:";
                        string_of_int @@ Mpd.Status.playlistlength status]
  | State -> let state = Mpd.Status.state status in
      ["state:"; Mpd.Status.string_of_state state]
  | Song -> ["song:"; string_of_int @@ Mpd.Status.song status]
  | Songid -> ["songid:"; string_of_int @@ Mpd.Status.songid status]
  | Nextsong -> ["nextsong:"; string_of_int @@ Mpd.Status.nextsong status]
  | Nextsongid -> ["nextsongid:"; string_of_int @@ Mpd.Status.nextsongid status]
  | Time -> ["time:"; Mpd.Status.time status]
  | Elapsed -> ["elapsed:"; string_of_float @@ Mpd.Status.elapsed status]
  | Duration -> ["duration:"; string_of_float @@ Mpd.Status.duration status]
  | Bitrate -> ["bitrate:"; string_of_int @@ Mpd.Status.bitrate status]
  | Xfade -> ["xfade:"; string_of_int @@ Mpd.Status.xfade status]
  | Mixrampdb -> ["mixrampdb:"; string_of_float @@ Mpd.Status.mixrampdb status]
  | Mixrampdelay -> ["mixrampdelay:"; string_of_float @@ Mpd.Status.mixrampdelay status]
  | Audio -> ["audio:"; Mpd.Status.audio status]
  | Updating_db -> ["updating_db:"; string_of_int @@ Mpd.Status.updating_db status]
  | Error -> ["error:"; Mpd.Status.error status]


let get_status common_opts fields =
  let {host; port} = common_opts in
  let client = initialize_client {host; port} in
  match Mpd.Client.status client with
  | Error message -> print_endline message
  | Ok status ->
      let rec _parse_fields = function
        | [] -> ()
        | i :: remain -> let info = String.concat " " @@ get_mpd_status_info status i in
        let _ = print_endline info in
        _parse_fields remain
        in
  let _ = _parse_fields fields in
  Mpd.Client.close client

let status_fields =
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
  let doc = "Get all status information with no arguments or chose those you want." in
  let man = [ `S Manpage.s_description;
              `P "Status commands in order to display Mpd server information.";
              `Blocks help_section
  ] in
  Term.(const get_status $ common_opts_t $ status_fields),
  Cmd.info "status" ~doc ~sdocs ~exits ~man
