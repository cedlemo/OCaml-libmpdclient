(*
 * Copyright 2017-2018 Cedric LE MOIGNE, cedlemo@gmx.com
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
open Mpd.Protocol

let version = "not.yet"
let sdocs = Manpage.s_common_options
let docs = Manpage.s_common_options
let exits = Cmd.Exit.defaults

let help _copts man_format cmds topic = match topic with
| None -> `Help (`Pager, None) (* help about the program. *)
| Some topic ->
    let topics = "topics" :: "patterns" :: "environment" :: cmds in
    let conv, _ = Cmdliner.Arg.enum (List.rev_map (fun s -> (s, s)) topics) in
    match conv topic with
    | `Error e -> `Error (false, e)
    | `Ok t when t = "topics" -> List.iter print_endline topics; `Ok ()
    | `Ok t when List.mem t cmds -> `Help (man_format, Some t)
    | `Ok _ ->
        let page = (topic, 7, "", "", ""), [`S topic; `P "Say something";] in
        `Ok (Cmdliner.Manpage.print man_format Format.std_formatter page)

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
    let env = Cmd.Env.info "OMPDC_HOST" ~doc in
    Arg.(value & opt string "127.0.0.1" & info ["h"; "host"] ~docs ~env ~docv:"HOST")
  in
  let port =
    let doc = "Set the port of the Mpd server." in
    let env = Cmd.Env.info "OMPDC_PORT" ~doc in
    Arg.(value & opt int 6600 & info ["p"; "port"] ~docs ~env ~docv:"PORT")
  in
  Term.(const common_opts $ host $ port)

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
  Cmd.info "help" ~doc ~exits ~man


let initialize_client {host; port} =
   let connection = Mpd.Connection.initialize host port in
   let client = Mpd.Client.initialize connection in
   let _ = print_endline ("Mpd server : " ^ (Mpd.Client.mpd_banner client)) in
   client

let check_for_mpd_error mpd_response =
  let response = (
    match mpd_response with
    | Ok msg -> (
      match msg with
      | None -> ""
      | Some str -> "Mpd response: " ^ str
    )
    | Error (ack_error, _ack_cmd_num, _ack_cmd, ack_message) ->
        String.concat " " ["Error type:";
                           Mpd.Protocol.error_name ack_error;
                           "-- error message:";
                           ack_message]
  )
  in
  print_endline response
