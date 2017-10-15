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

type t =
  { hostname : string; port : int; ip : Unix.inet_addr; socket : Lwt_unix.file_descr }

exception Mpd_Lwt_unix_exn of string

let fail_with_message m =
  Lwt.fail (Mpd_Lwt_unix_exn m)

let gethostbyname name =
  Lwt.catch
    (fun () ->
      Lwt_unix.gethostbyname name
      >>= fun entry ->
        let addrs = Array.to_list entry.Unix.h_addr_list in
        Lwt.return addrs
    )
    (function
      | Not_found -> let m = Printf.sprintf "Host not found, \
                                            Lwt_unix.gethostname: no host found\
                                            for %s. Exiting...\n" name in
          fail_with_message m
          >>= fun () -> Lwt.return_nil

      | e -> Lwt.fail e
    )

let open_socket addr port =
  Lwt.catch
    (fun () ->
      let sock = Lwt_unix.socket Lwt_unix.PF_INET Lwt_unix.SOCK_STREAM 0 in
      let sockaddr = Lwt_unix.ADDR_INET (addr, port) in
      Lwt_unix.connect sock sockaddr
      >>= fun () ->
        Lwt.return (Some sock)
    )
    (function
      | Unix.Unix_error (error, fn_name, param_name) ->
          Lwt_io.eprintf "%s, Unix.%s (%s): unable to open socket. Exiting...\n" (Unix.error_message error) fn_name param_name
          >>= fun () -> Lwt.return_none
      | e -> Lwt.fail e
    )

let initialize hostname port =
  gethostbyname hostname
  >>= function
    | None -> Lwt.return_none
    | Some addrs -> match addrs with
                    | [] -> Lwt.return_none
                    | addr :: others -> open_socket addr port
                        >>= function
                          | None -> Lwt.return_none
                          | Some socket ->
                              let conn = { hostname = hostname;
                                           port = port;
                                           ip = addr;
                                           socket = socket
                                         }
                              in Lwt.return (Some (conn))

let write conn str =
  Lwt.catch
  (fun () ->
    let {socket = socket; _} = conn in
    let len = String.length str in
    Lwt_unix.send socket str 0 len []
  )
  (function
      | Unix.Unix_error (error, fn_name, param_name) ->
          Lwt_io.eprintf "%s, Unix.%s (%s): unable to write to socket connected to %s:%s. Exiting...\n"
                         (Unix.error_message error)
                         fn_name
                         param_name
                         conn.hostname
                         (string_of_int conn.port)
          >>= fun () -> Lwt.return (-1)
      | e -> Lwt.fail e
  )

let recvstr conn =
  Lwt.catch
  (fun () ->
    let {socket = socket; _} = conn in
    let maxlen = 8 in
    let buffer = Bytes.create maxlen in
    Lwt_unix.recv socket buffer 0 maxlen []
    >>= fun recvlen ->
      Lwt.return (Some (String.sub buffer 0 recvlen))
  )
  (function
      | Unix.Unix_error (error, fn_name, param_name) ->
          Lwt_io.eprintf "%s, Unix.%s (%s): unable to read from socket connected to %s:%s. Exiting...\n"
                         (Unix.error_message error)
                         fn_name
                         param_name
                         conn.hostname
                         (string_of_int conn.port)
          >>= fun () -> Lwt.return_none
      | e -> Lwt.fail e
  )

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
    | Complete (s) -> Lwt.return (Some s)
    | Incomplete -> recvstr connection
                    >>= function
                      | None -> Lwt.return_none
                      | Some response -> _read connection (response :: acc)
    in _read connection []

let read_idle_events connection =
  read connection full_mpd_idle_event

let read_mpd_banner connection =
  read connection full_mpd_banner

let read_command_response connection =
  read connection full_mpd_command_response

let close conn =
  Lwt.catch
  (fun () ->
    let {socket = socket; _} = conn in
    Lwt_unix.close socket
  )
  (function
      | Unix.Unix_error (error, fn_name, param_name) ->
          Lwt_io.eprintf "%s, Unix.%s (%s): unable to read from socket connected to %s:%s. Exiting...\n"
                         (Unix.error_message error)
                         fn_name
                         param_name
                         conn.hostname
                         (string_of_int conn.port)
      | e -> Lwt.fail e
  )
