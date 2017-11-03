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

let playback_options common_opts consume crossfade mixrampdb random =
  let {host; port} = common_opts in
  let client = initialize_client {host; port} in
  let _ = match consume with
    | Some v -> ignore(Mpd.PlaybackOptions.consume client v)
    | None -> ()
  in
  let _ = match crossfade with
    | Some v -> ignore(Mpd.PlaybackOptions.crossfade client v)
    | None -> ()
  in
  let _ = match mixrampdb with
    | Some v -> ignore(Mpd.PlaybackOptions.mixrampdb client v)
    | None -> ()
  in
  let _ = match random with
    | Some v -> ignore(Mpd.PlaybackOptions.random client v)
    | None -> ()
  in
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
                                 $ mixrampdb $ random),
    Term.info "playback_options" ~doc ~sdocs ~exits ~man

