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

open Lwt

type t =
  { hostname : string;
    port : int;
    ip : Unix.inet_addr;
    socket : Lwt_unix.file_descr;
    mutable buffer : Bytes.t;
  }

exception Lwt_unix_exn of string

let fail_with_message m =
  Lwt.fail (Lwt_unix_exn m)

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
                                            for %s. Exiting..." name in
          fail_with_message m

      | e -> Lwt.fail e
    )

let open_socket addr port =
  Lwt.catch
    (fun () ->
      let sock = Lwt_unix.socket Lwt_unix.PF_INET Lwt_unix.SOCK_STREAM 0 in
      let sockaddr = Lwt_unix.ADDR_INET (addr, port) in
      Lwt_unix.connect sock sockaddr
      >>= fun () ->
        Lwt.return sock
    )
    (function
      | Unix.Unix_error (error, fn_name, param_name) ->
          let m = Printf.sprintf "%s, Unix.%s (%s): unable to open socket.
                                  Exiting..."
                                  (Unix.error_message error)
                                  fn_name
                                  param_name in
          fail_with_message m
      | e -> Lwt.fail e
    )

let initialize hostname port =
  gethostbyname hostname
  >>= fun addrs ->
    let addr = List.hd addrs in
    open_socket addr port
    >>= fun socket ->
      let conn = { hostname = hostname;
                   port = port;
                   ip = addr;
                   socket = socket;
                   buffer = Bytes.empty;
                 }
     in Lwt.return conn

let hostname connection =
  Lwt.return connection.hostname

let port connection =
  Lwt.return connection.port

let buffer connection =
  Lwt.return (Bytes.to_string connection.buffer)

let write conn str =
  Lwt.catch
  (fun () ->
    let {socket = socket; _} = conn in
    let b = Bytes.of_string str in
    let len = Bytes.length b in
    Lwt_unix.send socket b 0 len []
  )
  (function
      | Unix.Unix_error (error, fn_name, param_name) ->
          let m = Printf.sprintf "%s, Unix.%s (%s): unable to write to socket \
                                  connected to %s:%s. Exiting..."
                                  (Unix.error_message error)
                                  fn_name
                                  param_name
                                  conn.hostname
                                  (string_of_int conn.port) in
          fail_with_message m
      | e -> Lwt.fail e
  )

let recvstr conn =
  Lwt.catch
  (fun () ->
    let {socket = socket; _} = conn in
    let maxlen = 3 in
    let buf = Bytes.create maxlen in
    Lwt_unix.recv socket buf 0 maxlen []
    >>= fun recvlen ->
      Lwt.return Bytes.(sub buf 0 recvlen)
  )
  (function
      | Unix.Unix_error (error, fn_name, param_name) ->
          let m = Printf.sprintf "%s, Unix.%s (%s): unable to read from socket \
                                  connected to %s:%s. Exiting..."
                                  (Unix.error_message error)
                                  fn_name
                                  param_name
                                  conn.hostname
                                  (string_of_int conn.port) in
          fail_with_message m
      | e -> Lwt.fail e
  )

type mpd_response =
  | Incomplete
  | Complete of (string * int)

let check_full_response mpd_data pattern group useless_char =
  let response = Str.regexp pattern in
  match Str.string_match response mpd_data 0 with
  | true -> Complete (Str.matched_group group mpd_data, useless_char)
  | false -> Incomplete

let full_mpd_banner mpd_data =
  let pattern = "OK \\(\\(\n\\|.\\)*\\)\n" in
  check_full_response mpd_data pattern 1 4

let full_mpd_command_response mpd_data =
  let pattern = "\\(\\(\n\\|.\\)*\\)OK$" in
  check_full_response mpd_data pattern 0 3

let full_mpd_idle_event mpd_data =
  let pattern = "changed: \\(\\(\n\\|.\\)*\\)\nOK\n" in
  match check_full_response mpd_data pattern 2 3 with
  | Incomplete -> full_mpd_command_response mpd_data (* Check if there is an empty response that follow an noidle command *)
  | Complete response -> Complete response

let read connection check_full_data =
  let rec _read connection =
    let response = Bytes.to_string connection.buffer in
    match check_full_data response with
    | Complete (s, u) -> let s_length = String.length s in
        let start = (s_length - 1) + u in
        let length = (String.length response) - s_length in
        let _ = connection.buffer <- Bytes.sub connection.buffer start length in
        Lwt.return s
    | Incomplete -> recvstr connection
        >>= fun response -> let buf = Bytes.cat connection.buffer response in
        let _ = connection.buffer <- buf in _read connection
    in _read connection

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
          let m = Printf.sprintf "%s, Unix.%s (%s): unable to read from socket \
                                  connected to %s:%s. Exiting..."
                                  (Unix.error_message error)
                                  fn_name
                                  param_name
                                  conn.hostname
                                  (string_of_int conn.port) in
          fail_with_message m
      | e -> Lwt.fail e
  )
