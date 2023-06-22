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

let play common_opts song_pos =
  let {host; port} = common_opts in
  let client = initialize_client {host; port} in
  let _ = check_for_mpd_error @@ Mpd.Playback.play client song_pos in
  Mpd.Client.close client

let play_id common_opts song_id =
  let {host; port} = common_opts in
  let client = initialize_client {host; port} in
  let _ = check_for_mpd_error @@ Mpd.Playback.playid client song_id in
  Mpd.Client.close client

let song_pos =
  let doc = "Integer value that represents the position of a song in the current playlist." in
  Arg.(value & pos 0 int 0 & info [] ~doc ~docv:"SONG_POS")

let song_id =
  let doc = "Integer value that represents the id of a song." in
  Arg.(value & pos 0 int 0 & info [] ~doc ~docv:"SONG_ID")

let play_t =
    let doc = "Play the song at SONG_POS in the playlist"
    in
    let man = [
               `S Manpage.s_description;
               `P doc;
               `Blocks help_section; ]
    in
    Term.(const play $ common_opts_t $ song_pos),
    Cmd.info "play" ~doc ~sdocs ~exits ~man

let play_id_t =
    let doc = "Play the song SONG_ID."
    in
    let man = [
               `S Manpage.s_description;
               `P doc;
               `Blocks help_section; ]
    in
    Term.(const play $ common_opts_t $ song_id),
    Cmd.info "play_id" ~doc ~sdocs ~exits ~man

let time =
  let doc = "Float value that could represents the length of a song or the \
             starting point to play" in
  Arg.(value & pos 1 float 0.0 & info [] ~doc ~docv:"TIME")

let seek common_opts song_pos time =
  let {host; port} = common_opts in
  let client = initialize_client {host; port} in
  let _ = check_for_mpd_error @@ Mpd.Playback.seek client song_pos time in
  Mpd.Client.close client

let seek_id common_opts song_id time =
  let {host; port} = common_opts in
  let client = initialize_client {host; port} in
  let _ = check_for_mpd_error @@ Mpd.Playback.seekid client song_id time in
  Mpd.Client.close client

let seek_cur common_opts time =
  let {host; port} = common_opts in
  let client = initialize_client {host; port} in
  let _ = check_for_mpd_error @@ Mpd.Playback.seekcur client time in
  Mpd.Client.close client

let seek_t =
    let doc = "Play the song at SONG_POS in the playlist at TIME"
    in
    let man = [
               `S Manpage.s_description;
               `P doc;
               `Blocks help_section; ]
    in
    Term.(const seek $ common_opts_t $ song_pos $ time),
    Cmd.info "seek" ~doc ~sdocs ~exits ~man

let seek_id_t =
    let doc = "Play the song SONG_ID at TIME"
    in
    let man = [
               `S Manpage.s_description;
               `P doc;
               `Blocks help_section; ]
    in
    Term.(const seek_id $ common_opts_t $ song_id $ time),
    Cmd.info "seek_id" ~doc ~sdocs ~exits ~man

let seek_cur_t =
  let doc = "Play the current song at TIME" in
  let man = [
    `S Manpage.s_description;
    `P doc;
    `Blocks help_section; ] in
  Term.(const seek_cur $ common_opts_t $ time),
  Cmd.info "seek_cur" ~doc ~sdocs ~exits ~man

let next common_opts =
  let {host; port} = common_opts in
  let client = initialize_client {host; port} in
  let _ = check_for_mpd_error @@ Mpd.Playback.next client in
  Mpd.Client.close client

let next_t =
    let doc = "Play the next song in the playlist"
    in
    let man = [
               `S Manpage.s_description;
               `P doc;
               `Blocks help_section; ]
    in
    Term.(const next $ common_opts_t),
    Cmd.info "next" ~doc ~sdocs ~exits ~man

let previous common_opts =
  let {host; port} = common_opts in
  let client = initialize_client {host; port} in
  let _ = check_for_mpd_error @@ Mpd.Playback.previous client in
  Mpd.Client.close client

let previous_t =
    let doc = "Play the previous song in the playlist"
    in
    let man = [
               `S Manpage.s_description;
               `P doc;
               `Blocks help_section; ]
    in
    Term.(const previous $ common_opts_t),
    Cmd.info "previous" ~doc ~sdocs ~exits ~man

let stop common_opts =
  let {host; port} = common_opts in
  let client = initialize_client {host; port} in
  let _ = check_for_mpd_error @@ Mpd.Playback.stop client in
  Mpd.Client.close client

let stop_t =
    let doc = "Stop playing song."
    in
    let man = [
               `S Manpage.s_description;
               `P doc;
               `Blocks help_section; ]
    in
    Term.(const stop $ common_opts_t),
    Cmd.info "stop" ~doc ~sdocs ~exits ~man

let pause common_opts value =
  let {host; port} = common_opts in
  let client = initialize_client {host; port} in
  let _ = check_for_mpd_error @@ Mpd.Playback.pause client value in
  Mpd.Client.close client

let toggle_value =
  let doc = "Boolean value that switch between pause/play the current song." in
  Arg.(value & pos 0 bool true & info [] ~doc ~docv:"TOGGLE_VAL")

let pause_t =
    let doc = "Switch between play/pause."
    in
    let man = [
               `S Manpage.s_description;
               `P doc;
               `Blocks help_section; ]
    in
    Term.(const pause $ common_opts_t $ toggle_value),
    Cmd.info "pause" ~doc ~sdocs ~exits ~man

let cmds = [play_t; play_id_t; seek_t; seek_id_t; seek_cur_t; next_t; previous_t; stop_t; pause_t]
