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

(*
 * cmdliner :
 * http://erratique.ch/software/cmdliner/doc/Cmdliner.html#examples
 *
 * TODO : start implementing basic playbacks :
 * https://cedlemo.github.io/OCaml-libmpdclient/Mpd/Playback/index.html
 *
 * ompdc playback play
 * ompdc playback stop
 * ompdc playback next
 * ompdc playback prev
 * ompdc playback pause
 * ompdc playback seekcur
 * other commands need to be able to read the playlist
 * *)
(* let host = "127.0.0.1"
let port = 6600 *)
open Cmdliner

let ompdc host =
  print_endline host

let host =
  let doc = "Set the address of the Mpd server." in
  let env = Arg.env_var "MPD_HOST" ~doc in
  Arg.(value & opt string "127.0.0.1" & info ["h"; "host"] ~env ~docv:"HOST")

let ompdc_t = Term.(const ompdc $host)

let info =
  let doc = "A simple Mpd client written in OCaml" in
  let man = [
    `S Manpage.s_bugs;
    `P "Send issue at https://github.com/cedlemo/OCaml-libmpdclient/issues"
  ]
  in
  Term.info "ompdc" ~version:"not yet" ~doc ~exits:Term.default_exits ~man

let () = Term.exit @@ Term.eval (ompdc_t, info)
