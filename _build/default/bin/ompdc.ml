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

let default_cmd =
  let doc = "a Mpd client written in OCaml." in
  let man = help_section in
  Term.(ret (const (fun _ -> `Help (`Pager, None)) $ common_opts_t)),
  Term.info "ompdc" ~version ~doc ~sdocs ~exits ~man

let cmds = List.concat [Ompdc_playback.cmds;
                         [Ompdc_status.cmd;
                          Ompdc_idle.cmd;
                          Ompdc_playback_options.cmd;
                          help_cmd]
                       ]

let () = Term.(exit @@ eval_choice default_cmd cmds)
