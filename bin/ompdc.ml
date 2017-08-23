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

let version = "not.yet"
let sdocs = Manpage.s_common_options
let docs = Manpage.s_common_options
let exits = Term.default_exits

let help copts man_format cmds topic = match topic with
| None -> `Help (`Pager, None) (* help about the program. *)
| Some topic ->
    let topics = "topics" :: "patterns" :: "environment" :: cmds in
    let conv, _ = Cmdliner.Arg.enum (List.rev_map (fun s -> (s, s)) topics) in
    match conv topic with
    | `Error e -> `Error (false, e)
    | `Ok t when t = "topics" -> List.iter print_endline topics; `Ok ()
    | `Ok t when List.mem t cmds -> `Help (man_format, Some t)
    | `Ok t ->
        let page = (topic, 7, "", "", ""), [`S topic; `P "Say something";] in
        `Ok (Cmdliner.Manpage.print man_format Format.std_formatter page)


(* Help sections common to all commands *)

let help_section = [
  `S Manpage.s_common_options;
  `P "These options are common to all commands.";
  `S Manpage.s_bugs; `P "Check bug reports at https://github.com/cedlemo/OCaml-libmpdclient/issues";
  `S Manpage.s_authors; `P "Cedric Le Moigne <cedlemo at gmx dot com>"
        ]

(* Options common to all commands *)
type mpd_opts = {host : string; port : int}

let common_opts host port =
  {host; port}

let common_opts_t =
  let host =
    let doc = "Set the address of the Mpd server." in
    let env = Arg.env_var "OMPDC_HOST" ~doc in
    Arg.(value & opt string "127.0.0.1" & info ["h"; "host"] ~docs ~env ~docv:"HOST")
  in
  let port =
    let doc = "Set the port of the Mpd server." in
    let env = Arg.env_var "OMPDC_PORT" ~doc in
    Arg.(value & opt int 6600 & info ["p"; "port"] ~docs ~env ~docv:"PORT")
  in
  Term.(const common_opts $ host $ port)

let initialize_client {host; port} =
   let connection = Mpd.Connection.initialize host port in
   let client = Mpd.Client.initialize connection in
   let _ = print_endline ("Mpd server : " ^ (Mpd.Client.mpd_banner client)) in
   client

let play common_opts song_id =
  let {host; port} = common_opts in
  let client = initialize_client {host; port} in
  let _ = Mpd.Playback.play client song_id in
  Mpd.Client.close client

let song_id =
  let doc = "Integer value that represents the id of a song in the current playlist." in
  Arg.(value & pos 0 int 0 & info [] ~doc ~docv:"SONG_ID")

let play_t =
    let doc = "Play the song SONG_ID in the playlist"
    in
    let man = [
               `S Manpage.s_description;
               `P doc;
               `Blocks help_section; ]
    in
    Term.(const play $ common_opts_t $ song_id),
    Term.info "play" ~doc ~sdocs ~exits ~man

let next common_opts =
  let {host; port} = common_opts in
  let client = initialize_client {host; port} in
  let _ = Mpd.Playback.next client in
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
    Term.info "next" ~doc ~sdocs ~exits ~man

let prev common_opts =
  let {host; port} = common_opts in
  let client = initialize_client {host; port} in
  let _ = Mpd.Playback.prev client in
  Mpd.Client.close client

let prev_t =
    let doc = "Play the previous song in the playlist"
    in
    let man = [
               `S Manpage.s_description;
               `P doc;
               `Blocks help_section; ]
    in
    Term.(const prev $ common_opts_t),
    Term.info "prev" ~doc ~sdocs ~exits ~man

let stop common_opts =
  let {host; port} = common_opts in
  let client = initialize_client {host; port} in
  let _ = Mpd.Playback.stop client in
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
    Term.info "stop" ~doc ~sdocs ~exits ~man

let pause common_opts value =
  let {host; port} = common_opts in
  let client = initialize_client {host; port} in
  let _ = Mpd.Playback.pause client value in
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
    Term.info "pause" ~doc ~sdocs ~exits ~man

let help_cmd =
  let topic =
    let doc = "The topic to get help on. `topics' lists the topics." in
    Arg.(value & pos 0 (some string) None & info [] ~docv:"TOPIC" ~doc)
  in
  let doc = "display help about ompdc and ompdc commands" in
  let man =
    [`S Manpage.s_description;
     `P "Prints help about ompdc commands and other subjects...";
     `Blocks help_section; ]
  in
  Term.(ret
          (const help $ common_opts_t $ Arg.man_format $ Term.choice_names $topic)),
  Term.info "help" ~doc ~exits ~man


let default_cmd =
  let doc = "a Mpd client written in OCaml." in
  let man = help_section in
  Term.(ret (const (fun _ -> `Help (`Pager, None)) $ common_opts_t)),
  Term.info "ompdc" ~version ~doc ~sdocs ~exits ~man
let cmds = [play_t; next_t; prev_t; stop_t;pause_t; help_cmd]

let () = Term.(exit @@ eval_choice default_cmd cmds)
