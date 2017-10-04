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

open Lwt

type c =
  { hostname : string; port : int; ip : Unix.inet_addr; socket : Lwt_unix.file_descr }

let gethostbyname name =
Lwt.catch
  (fun () ->
    Lwt_unix.gethostbyname name
    >>= fun entry ->
      let addrs = Array.to_list entry.Unix.h_addr_list in
      Lwt.return addrs
  )
  (function
    | Not_found -> Lwt.return_nil
    | e -> Lwt.fail e
  )

let open_socket addr port =
  let sock = Lwt_unix.socket Lwt_unix.PF_INET Lwt_unix.SOCK_STREAM 0 in
  let sockaddr = Lwt_unix.ADDR_INET (addr, port) in
  Lwt_unix.connect sock sockaddr
  >>= fun () ->
    Lwt.return sock

let initialize hostname port =
  gethostbyname hostname
  >>= fun addrs ->
    match addrs with
    | [] -> Lwt.return None
    | addr :: others -> open_socket addr port
                        >>= fun socket ->
                          let conn = { hostname = hostname;
                                       port = port;
                                       ip = addr;
                                       socket = socket
                                     }
                          in Lwt.return (Some (conn))

let write conn str =
  let {socket = socket; _} = conn in
  let len = String.length str in
  Lwt_unix.send socket str 0 len []
  >>=fun success ->
    Lwt.return ()

let recvstr conn =
  let {socket = socket; _} = conn in
  let maxlen = 8 in
  let buffer = Bytes.create maxlen in
  Lwt_unix.recv socket buffer 0 maxlen [] >|= String.sub buffer 0
  (* Equivalent to
   * let buf = Bytes.create 128 in
   * Lwt_unix.recv sock buf 0 128 []
   * >>= fun recvlen ->
   *   String.sub buf 0 recvlen in *)

type mpd_response =
  | Incomplete
  | Complete of string

let check_full_response mpd_data pattern group =
  let response = Str.regexp pattern in
  match Str.string_match response mpd_data 0 with
  | true -> Complete (Str.matched_group group mpd_data)
  | false -> Incomplete

let full_mpd_idle_event mpd_data =
  let pattern = "changed: \\(\\(\n\\|.\\)*\\)\nOK\n" in
  check_full_response mpd_data pattern 1

let full_mpd_banner mpd_data =
  let pattern = "OK\\(\\(\n\\|.\\)*\\)\n" in
  check_full_response mpd_data pattern 1

let full_mpd_command_response mpd_data =
  let pattern = "\\(\\(\n\\|.\\)*\\)OK\n" in
  check_full_response mpd_data pattern 0

let read connection check_full_data =
  let rec _read connection acc =
    let response = String.concat "" (List.rev acc) in
    match check_full_data response with
    | Complete (s) -> Lwt.return s
    | Incomplete -> recvstr connection
                    >>= fun response ->
                    _read connection (response :: acc)
  in _read connection []

let read_idle_events connection =
  read connection full_mpd_idle_event

let read_mpd_banner connection =
  read connection full_mpd_banner

let read_command_response connection =
  read connection full_mpd_command_response

let close conn =
  let {socket = socket; _} = conn in
  Lwt_unix.close socket
