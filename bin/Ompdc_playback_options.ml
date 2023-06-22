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

module Pb_opt = Mpd.Playback_options

let consume =
  let doc = "Sets consume state to STATE, STATE should be false or true.
    When consume is activated, each song played is removed from playlist." in
  let docv = "STATE" in
  Arg.(value & opt (some bool) None & info ["c"; "consume"] ~docs ~doc ~docv)

let crossfade =
  let doc = "Sets crossfade XFADE between songs in seconds." in
  let docv = "XFADE" in
  Arg.(value & opt (some int) None & info ["xf"; "crossfade"] ~docs ~doc ~docv)

let mixrampdb =
  let doc = "Sets the threshold at which songs will be overlapped.
    Like crossfading but doesn't fade the track volume, just overlaps. The
    songs need to have MixRamp tags added by an external tool. 0dB is the
    normalized maximum volume so use negative values, I prefer -17dB.
    In the absence of mixramp tags crossfading will be used.
    See http://sourceforge.net/projects/mixramp" in
  let docv = "MIXRAMPDB" in
  Arg.(value & opt (some int) None & info ["mixrampdb"] ~docs ~doc ~docv)

let random =
  let doc = "Sets random state to RAND_STATE, RAND_STATE should be true or
  false" in
  let docv = "RAND_STATE" in
  Arg.(value & opt (some bool) None & info ["rand"; "random"] ~docs ~doc ~docv)

let repeat =
  let doc = "Sets repeat state to REPEAT_STATE, REPEAT_STATE should be false \
             or true." in
  let docv = "REPEAT_STATE" in
  Arg.(value & opt (some bool) None & info ["rep"; "repeat"] ~docs ~doc ~docv)

let setvol =
  let doc = "Sets volume to VOL, the range of volume is 0-100" in
  let docv = "VOL" in
  Arg.(value & opt (some int) None & info ["vol"; "volume"] ~docs ~doc ~docv)

let single =
  let doc = "Sets single state to SINGLE_STATE, SINGLE_STATE should be 0 or 1. When single is
    activated, playback is stopped after current song, or song is repeated if
    the 'repeat' mode is enabled." in
  let docv = "SINGLE_STATE" in
  Arg.(value & opt (some bool) None & info ["single"] ~docs ~doc ~docv)

let mixrampdelay =
  let doc = "Additional time subtracted from the overlap calculated by mixrampdb. A
    value of \"nan\" disables MixRamp overlapping and falls back to crossfading." in
  let docv = "MIXRAMP_DELAY" in
  Arg.(value & opt (some string) None & info ["mixrampdelay"] ~docs ~doc ~docv)

let mixrampdelay_wrapper client value =
  let string_parse str =
    match str with
    | "nan" -> Pb_opt.Nan
    | _ -> try Pb_opt.Seconds (float_of_string str)
      with Failure _ -> Pb_opt.Nan
  in
  Pb_opt.mixrampdelay client (string_parse value)

let replay_gain_mode =
  let doc = "Sets the replay gain mode. One of off, track, album, auto with
    default (value given) set to auto.
    Changing the mode during playback may take several seconds, because the
    new settings does not affect the buffered data.
    This command triggers the options idle event." in
  let docv = "REPLAY_GAIN_MODE" in
  Arg.(value & opt (some string) None & info ["replay_gain_mode"] ~docs ~doc ~docv)

let replay_gain_mode_wrapper client value =
  let string_parse = function
    | "album" -> Pb_opt.Album
    | "auto" -> Pb_opt.Auto
    | "off" -> Pb_opt.Off
    | "track" -> Pb_opt.Track
    | _ -> Pb_opt.Auto
  in Pb_opt.replay_gain_mode client (string_parse value)

let playback_options common_opts consume crossfade mixrampdb random repeat
                                 setvol single mixrampdelay replay_gain_mode =
  let {host; port} = common_opts in
  let client = initialize_client {host; port} in
  let on_value_do opt_val fn =
    match opt_val with
    | Some v -> check_for_mpd_error (fn client v)
    | None -> ()
  in
  on_value_do consume Pb_opt.consume;
  on_value_do crossfade Pb_opt.crossfade;
  on_value_do mixrampdb Pb_opt.mixrampdb;
  on_value_do random Pb_opt.random;
  on_value_do repeat Pb_opt.repeat;
  on_value_do setvol Pb_opt.setvol;
  on_value_do single Pb_opt.single;
  on_value_do mixrampdelay mixrampdelay_wrapper;
  on_value_do replay_gain_mode replay_gain_mode_wrapper;
  Mpd.Client.close client

let cmd =
    let doc = "Configure all the playback options of the Mpd server."
    in
    let man = [
               `S Manpage.s_description;
               `P doc;
               `Blocks help_section; ]
    in
    Term.(const playback_options $ common_opts_t $ consume $ crossfade
                                 $ mixrampdb $ random $ repeat $ setvol
                                 $ single $ mixrampdelay $ replay_gain_mode),
    Cmd.info "playback_options" ~doc ~sdocs ~exits ~man
