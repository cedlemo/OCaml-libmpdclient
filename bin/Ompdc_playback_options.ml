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

let playback_options common_opts consume =
  let {host; port} = common_opts in
  let client = initialize_client {host; port} in
  let _ = match consume with
    | Some consume_bool -> ignore(Mpd.PlaybackOptions.consume client consume_bool)
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
    Term.(const playback_options $ common_opts_t $ consume),
    Term.info "playback_options" ~doc ~sdocs ~exits ~man

