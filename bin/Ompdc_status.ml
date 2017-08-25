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

let info common_opts name =
  let show_message host port name =
    let _args = match args with | None -> "no args" | Some s -> s in
    let message = Printf.sprintf "%s:%d %s" host port name in
    print_endline message
  in
  let {host; port} = common_opts in
  match cmd with
  | `Next -> show_message host port "next" args
  | `Pause -> show_message host port "pause" args
  | `Play -> show_message host port "play" args
  | `Prev -> show_message host port "prev" args
  | `Stop -> show_message host port "stop" args

let status_infos =
  let infos = ["volume", `Volume;
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
  ] in
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
  Arg.(required & pos 0 (some status_info) None & info [] ~doc ~docv:"INFO")

(* TODO let status_t = *)
