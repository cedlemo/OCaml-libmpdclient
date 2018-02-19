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

let reporter path =
  let open Logs in
  let buf_fmt ~like =
    let b = Buffer.create 512 in
    Fmt.with_buffer ~like b,
    fun () -> let m = Buffer.contents b in Buffer.reset b; m
  in
  let app, app_flush = buf_fmt ~like:Fmt.stdout in
  let dst, dst_flush = buf_fmt ~like:Fmt.stderr in
  let reporter = Logs_fmt.reporter ~app ~dst () in
  let report src level ~over k msgf =
    let k () =
      let write () =
        let flags = [Unix.O_WRONLY; Unix.O_CREAT; Unix.O_APPEND] in
        let perm = 0o777 in
        let log_file = path ^ "/libmpdclient.log" in
        let err_file =  path ^ "/libmpdclient.err" in
        Lwt_io.open_file ~flags ~perm ~mode:Lwt_io.Output log_file
        >>= fun fd_log ->
          Lwt_io.open_file ~flags ~perm ~mode:Lwt_io.Output err_file
          >>= fun fd_err ->
            Lwt.return (fd_log, fd_err)
            >>= fun (fd_log', fd_err') ->
              match level with
              | Logs.App -> Lwt_io.write fd_log' (app_flush ())
              | _ -> Lwt_io.write fd_err' (dst_flush ())
                >>= fun () ->
                  Lwt_io.close fd_log'
                  >>= fun () ->
                    Lwt_io.close fd_err'
      in
      let unblock () = over (); Lwt.return_unit in
      Lwt.finalize write unblock |> Lwt.ignore_result;
      k ()
    in
    reporter.Logs.report src level ~over:(fun () -> ()) k msgf;
  in
  { Logs.report = report }

let file_exists f = try ignore (Unix.stat f); true with _ -> false

let setup () =
  try
    let home = Sys.getenv "HOME" in
    let config = Printf.sprintf "%s/.config" home in
    let path = config ^ "/rameau" in
    let _ = if not (file_exists config) then Unix.mkdir config 0o755 in
    let _ = if not (file_exists path) then Unix.mkdir path 0o755 in
    Logs.set_reporter (reporter path);
    Logs.set_level (Some Debug);
    Lwt.return_unit
  with
  | Not_found -> Lwt.fail_with "Unable to get the HOME env variable"
  | Unix.Unix_error (e, _, _) -> let message = Unix.error_message e in
      Lwt.fail_with message

let _log message =
  Logs_lwt.debug (fun m -> m "%s" message)

let _err message =
  Logs_lwt.err (fun m -> m "%s" message)


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
  setup ()
  >>= fun () ->
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

let recvbytes conn =
  Lwt.catch
  (fun () ->
    let {socket = socket; _} = conn in
    let maxlen = 1024 in
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

let request_response mpd_data =
  let pattern = "\\(\\(\n\\|.\\)*OK\n\\)" in
  check_full_response mpd_data pattern 1 0

let command_response mpd_data =
  let pattern = "^\\(OK\n\\)\\(\n\\|.\\)*" in
  check_full_response mpd_data pattern 1 0

let full_mpd_idle_event mpd_data =
  let pattern = "changed: \\(\\(\n\\|.\\)*\\)OK\n" in
  match check_full_response mpd_data pattern 1 13 with
  | Incomplete -> command_response mpd_data (* Check if there is an empty response that follow an noidle command *)
  | Complete response -> Complete response

let read connection check_full_data =
  let rec _read connection =
    let response = Bytes.to_string connection.buffer in
    match check_full_data response with
    | Complete (s, u) -> let s_length = (String.length s) + u in
        let buff_len = String.length response in
        if s_length = buff_len then
          Logs_lwt.err (fun m -> m "matched : %s buf: %s then empty" s response)
          >>= fun () ->
          let _ = connection.buffer <- Bytes.empty in
          Lwt.return s
        else
          let start = s_length - 1 in
          let length = buff_len - s_length in
          let _ = connection.buffer <- Bytes.sub connection.buffer start length in
          Logs_lwt.err (fun m -> m "matched : %s buf: %s then remain o_%s_o" s response (Bytes.to_string connection.buffer))
        >>= fun () ->

          Lwt.return s
    | Incomplete -> recvbytes connection
        >>= fun b -> let buf = Bytes.cat connection.buffer b in
        let _ = connection.buffer <- buf in
        Logs_lwt.err (fun m -> m "-|%s|-" (Bytes.to_string buf))
        >>= fun () ->
        _read connection
    in
    _read connection

let read_idle_events connection =
  read connection full_mpd_idle_event

let read_mpd_banner connection =
  read connection full_mpd_banner

let read_request_response connection =
  read connection request_response

let read_command_response connection =
  read connection command_response

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
