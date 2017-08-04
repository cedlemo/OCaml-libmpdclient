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
(* open Cmdliner

let ompdc host port =
  let msg = String.concat " " [host; ":"; string_of_int port] in
  print_endline msg

let host =
  let doc = "Set the address of the Mpd server." in
  let env = Arg.env_var "MPD_HOST" ~doc in
  Arg.(value & opt string "127.0.0.1" & info ["h"; "host"] ~env ~docv:"HOST")

let port =
  let doc = "Set the port of the Mpd server." in
  let env = Arg.env_var "OMPDC_PORT" ~doc in
  Arg.(value & opt int 6600 & info ["p"; "port"] ~env ~docv:"PORT")

let ompdc_t = Term.(const ompdc $host $port)

let info =
  let doc = "A simple Mpd client written in OCaml" in
  let man = [
    `S Manpage.s_bugs;
    `P "Send issue at https://github.com/cedlemo/OCaml-libmpdclient/issues"
  ]
  in
  Term.info "ompdc" ~version:"not yet" ~doc ~exits:Term.default_exits ~man

let () = Term.exit @@ Term.eval (ompdc_t, info)
*)

(* Import from darcs example. *)
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
open Cmdliner
type mpd_opts = {host : string; port : int}

(* Help sections common to all commands *)

let help_section = [
  `S Manpage.s_common_options;
  `P "These options are common to all commands.";
  `S "MORE HELP";
  `P "Use `$(mname) $(i, COMMAND) --help' for help on a single command."; `Noblank;
  `S Manpage.s_bugs; `P "Check bug reports at https://github.com/cedlemo/OCaml-libmpdclient/issues";]

(* Options common to all commands *)
let common_opts host port =
  {host; port}

let common_opts_t =
  let docs = Manpage.s_common_options in
  let host =
    let doc = "Set the address of the Mpd server." in
    let env = Arg.env_var "MPD_HOST" ~doc in
    Arg.(value & opt string "127.0.0.1" & info ["h"; "host"] ~env ~docv:"HOST")
  in
  let port =
    let doc = "Set the port of the Mpd server." in
    let env = Arg.env_var "OMPDC_PORT" ~doc in
    Arg.(value & opt int 6600 & info ["p"; "port"] ~env ~docv:"PORT")
  in
  Term.(const common_opts $ host $ port)

(* Commands *)

type playback_cmds = Play | Next | Prev | Pause | Stop
let playback_cmds_to_string = function
  | Next -> "next"
  | Pause -> "pause"
  | Play -> "play"
  | Prev -> "prev"
  | Stop -> "stop"


let initialize_client {host; port} =
   let connection = Mpd.Connection.initialize host port in
   let client = Mpd.Client.initialize connection in
   let _ = print_endline ("Mpd server : " ^ (Mpd.Client.mpd_banner client)) in
   client

let playback common_opts cmd =
  let {host; port} = common_opts in
  let client = initialize_client {host; port} in
  let cmd_str = playback_cmds_to_string cmd in
  let _ = match cmd with
    | Next -> ignore (Mpd.Playback.next client)
    | Pause -> ignore (Mpd.Playback.pause client true)
    | Play -> ignore (Mpd.Playback.play client 1)
    | Prev -> ignore (Mpd.Playback.prev client)
    | Stop -> ignore (Mpd.Playback.stop client)
  in
  let message = Printf.sprintf "%s:%d %s" host port cmd_str in
  print_endline message

let playback_action =
    let doc = "Play next song." in
    let next = Next, Arg.info ["next"] ~doc in
    let doc = "Toggle Play/Stop." in
    let pause = Pause, Arg.info ["pause"] ~doc in
    let doc = "Play the current song in the Mpd queue." in
    let play = Play, Arg.info ["play"] ~doc in
    Arg.(last & vflag_all [Pause] [next; pause; play])

let playback_t =
    let doc = "Playback commands"
    in
    let exits = Term.default_exits in
    let man = [
               `S Manpage.s_description;
               `P "Playback commands for the current playlist (queue).";
               `Blocks help_section; ]
    in
    Term.(const playback $ common_opts_t $ playback_action),
    Term.info "playback" ~doc ~sdocs:Manpage.s_common_options ~exits ~man

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
  Term.info "help" ~doc ~exits:Term.default_exits ~man

let default_cmd =
  let doc = "a Mpd client written in OCaml." in
  let sdocs = Manpage.s_common_options in
  let exits = Term.default_exits in
  let man = help_section in
  Term.(ret (const (fun _ -> `Help (`Pager, None)) $ common_opts_t)),
  Term.info "ompdc" ~version:"v1.0.1" ~doc ~sdocs ~exits ~man

let cmds = [playback_t; help_cmd]

let () = Term.(exit @@ eval_choice default_cmd cmds)
