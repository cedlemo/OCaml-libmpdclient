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

let playback common_opts cmd args =
  let show_message host port cmd args =
    let _args = match args with | None -> "no args" | Some s -> s in
    let message = Printf.sprintf "%s:%d %s %s" host port cmd _args in
    print_endline message
  in
  let {host; port} = common_opts in
  match cmd with
  | `Next -> show_message host port "next" args
  | `Pause -> show_message host port "pause" args
  | `Play -> show_message host port "play" args
  | `Prev -> show_message host port "prev" args
  | `Stop -> show_message host port "stop" args

let playback_actions =
  let actions = ["play", `Play;
                 "stop", `Stop;
                 "prev", `Prev;
                 "next", `Next;
                 "pause", `Pause
  ] in
  let substitue = Printf.sprintf in
  let action_docs = List.map (fun (str, sym) ->
    match sym with
    | `Play -> substitue "$(b,%s) [ARG]" str
    | `Pause -> substitue "$(b,%s) [ARG]" str
    | `Stop | `Prev | `Next -> substitue "$(b,%s)" str
  ) actions in
  let doc = substitue "The action to perform. $(docv) must be one of: %s."
      (String.concat ", " action_docs)
  in
  let action = Arg.enum actions in
  Arg.(required & pos 0 (some action) None & info [] ~doc ~docv:"ACTION")

let playback_args =
  let doc = "An argument if the action need it. In playback mode, only the
  $(b,play) and $(b,pause) actions accept an argument.
  $(b,play) take an integer for the song id to play. $(b,pause) take a
  boolean in order to switch between play/pause." in
  Arg.(value & pos 1 (some string) None & info [] ~doc ~docv:"ARG")

let playback_t =
    let doc = "Playback commands"
    in
    let man = [
               `S Manpage.s_description;
               `P "Playback commands for the current playlist (queue).";
               `Blocks help_section; ]
    in
    Term.(const playback $ common_opts_t $ playback_actions $ playback_args),
    Term.info "playback" ~doc ~sdocs ~exits ~man

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

let cmds = [playback_t; help_cmd]

let () = Term.(exit @@ eval_choice default_cmd cmds)
