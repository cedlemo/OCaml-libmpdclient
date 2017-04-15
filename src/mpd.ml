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

(** Libmpd client main module *)

(* https://www.musicpd.org/doc/protocol/tags.html
 * https://www.musicpd.org/doc/protocol/playback_option_commands.html
 * https://www.musicpd.org/doc/protocol/playback_commands.html
 * https://www.musicpd.org/doc/protocol/queue.html
 * https://www.musicpd.org/doc/protocol/database.html
 * https://www.musicpd.org/doc/protocol/mount.html
 * https://www.musicpd.org/doc/protocol/stickers.html
 * https://www.musicpd.org/doc/protocol/connection_commands.html
 * https://www.musicpd.org/doc/protocol/output_commands.html
 * https://www.musicpd.org/doc/protocol/reflection_commands.html
 * https://www.musicpd.org/doc/protocol/client_to_client.html
 * *)

open Sys
open Unix
open Protocol
open Status
open Mpd_utils
open Lwt

module Utils = struct
  include Mpd_utils
end

(** Offer functions and type in order to handle connections to the mpd server at
   the socket level *)
module Connection : sig
  type c

  val initialize : string -> int -> c
  val close : c -> unit
  val socket: c -> Unix.file_descr
  val write: c -> string -> unit
  val read: c -> string
end = struct

  (** connection type *)
  type c =
    { hostname : string; port : int; ip : Unix.inet_addr; socket : Unix.file_descr }

  (** Create the connection, exit if the connection can not be initialized. *)
  let initialize hostname port =
    let ip = try (Unix.gethostbyname hostname).h_addr_list.(0)
    with Not_found ->
      prerr_endline (hostname ^ ": Host not found");
               exit 2
    in let socket = Unix.socket PF_INET SOCK_STREAM 0
    in let _ = Unix.connect socket (ADDR_INET(ip, port))
    in { hostname = hostname; port = port; ip = ip; socket = socket}

  (** Close the connection *)
  let close { socket; _} =
    let _ = Unix.set_nonblock socket
    in Unix.close socket

  (** Get the socket on which the connection is based *)
  let socket { socket; _} = socket

  (** Write to an Mpd connection *)
  let write c str =
    let socket = socket c in
    let len = String.length str in
    ignore(send socket str 0 len [])

  (** Read in an Mpd connection *)
  let read c =
    let socket = socket c in
    let _ = Unix.set_nonblock socket in
    let str = Bytes.create 128 in
    let rec _read s acc =
      try
        let recvlen = Unix.recv s str 0 128 [] in
        let recvstr = String.sub str 0 recvlen in _read s (recvstr :: acc)
    with
        | Unix_error(Unix.EAGAIN, _, _) -> if acc = [] then _read s acc else acc
        in String.concat "" (List.rev (_read socket []))
end

(** Provides functions and type in order to communicate to the mpd server
 with commands and requests. *)
module Client : sig
  type c

  val initialize: Connection.c -> c
  val send: c -> string -> Protocol.response
  val mpd_banner: c -> string
  val status: c -> Status.s
  val ping: c -> Protocol.response
  val password: c -> string -> Protocol.response
  val close: c -> unit
  val tagtypes: c -> string list
  (* val tagtypes_disable: c -> string list -> Protocol.response
  val tagtypes_clear: c -> Protocol.response
  val tagtypes_all: c -> Protocol.response *)
end = struct
  (** Client type *)
  type c = {connection : Connection.c; mpd_banner : string }

  (** Initialize the client with a connection. *)
  let initialize connection =
    let message = Connection.read connection in
    {connection = connection; mpd_banner = message}

  (** Send to the mpd server a command or a request. The response of the server
   is returned under the form of a Protocol.response type. *)
  let send client mpd_cmd =
    let {connection = c; _} = client in
    Connection.write c (mpd_cmd ^ "\n");
    let response = Connection.read c in
    Protocol.parse_response response

  (** Return the mpd banner that the server send at the first connection of the
   client. *)
  let mpd_banner {mpd_banner = banner; _ } =
    banner

  (** Create a status request and returns the status under a Mpd.Status.s
   type.*)
  let status client =
    let response = send client "status" in
    match response with
    | Ok (lines) -> let status_pairs = Utils.split_lines lines in
    Status.parse status_pairs
    | Error (ack, ack_cmd_num, cmd, error) -> Status.generate_error error

  (** Does nothing but return "OK". *)
  let ping client =
    send client "ping"

  (** This is used for authentication with the server. PASSWORD is simply the
   plaintext password. *)
  let password client mdp =
    send client (String.concat " " ["password"; mdp])

  (** Shows a list of available tag types. It is an intersection of the
   metadata_to_use setting and this client's tag mask.
   About the tag mask: each client can decide to disable any number of tag
   types, which will be omitted from responses to this client. That is a good
   idea, because it makes responses smaller. The following tagtypes sub
   commands configure this list. *)
  let tagtypes client =
    let response = send client "tagtypes" in
    match response with
    | Ok (lines) -> let tagid_keys_vals = Utils.split_lines lines in
    List.rev (values_of_pairs tagid_keys_vals)
    | Error (ack, ack_cmd_num, cmd, error) -> []
  (*
  (** Remove one or more tags from the list of tag types the client is
   * interested in. These will be omitted from responses to this client. *)
  let tagtypes_disable client tagtypes =
    send client (String.concat "" ["tagtypes disable ";
                                    String.concat " " tagtypes])
  (** Re-enable one or more tags from the list of tag types for this client.
   * These will no longer be hidden from responses to this client. *)
  let tagtypes_enable client tagtypes =
    send client (String.concat "" ["tagtypes enable ";
                                   String.concat " " tagtypes])

  (** Clear the list of tag types this client is interested in. This means that
   * MPD will not send any tags to this client. *)
  let tagtypes_clear client =
    send client "tagtypes clear"

  (** Announce that this client is interested in all tag types. This is the
   * default setting for new clients. *)
  let tagtypes_all client =
    send client "tagtypes all"
   *)

  (** Closes the connection to MPD. MPD will try to send the remaining output
   buffer before it actually closes the connection, but that cannot be
   guaranteed. This command will not generate a response. *)
  let close client =
    let {connection = c; _} = client in
    Connection.write c ("close\n");
    Connection.close c;
end

(** Offer functions and type in order to handle connections to the mpd server at
   the socket level in Lwt thread. *)
module LwtConnection : sig
  type c

  val initialize : string -> int -> c option Lwt.t
  val write: c -> string -> unit Lwt.t
  val read_mpd_banner: c -> string Lwt.t
  val read_idle_events: c -> string Lwt.t
  val read_command_response: c -> string Lwt.t
  val close: c -> unit Lwt.t
end = struct
  (** Lwt connection type for thread usage *)
  type c =
    { hostname : string; port : int; ip : Unix.inet_addr; socket : Lwt_unix.file_descr }

  let gethostbyname name =
  Lwt.catch
    (fun () ->
    Lwt_unix.gethostbyname name
    >>= fun entry ->
      let addrs = Array.to_list entry.Unix.h_addr_list in
      Lwt.return addrs
  ) (function
    | Not_found -> Lwt.return_nil
    | e -> Lwt.fail e
    )

  let open_socket addr port =
    let sock = Lwt_unix.socket Lwt_unix.PF_INET Lwt_unix.SOCK_STREAM 0 in
    let sockaddr = Lwt_unix.ADDR_INET (addr, port) in
    Lwt_unix.connect sock sockaddr
    >>= fun () ->
      Lwt.return sock

  (** Create the connection in a Lwt thread, returns None if the connection
   can not be initialized. *)
  let initialize hostname port =
    gethostbyname hostname >>= fun addrs ->
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

  (** Write in a Mpd connection throught a Lwt thread. *)
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
end

(** Provides functions and type in order to communicate to the mpd server
 with commands and requests in Lwt threads. *)
module LwtClient : sig
  type c

  val initialize: LwtConnection.c -> c Lwt.t
  val close: c -> unit Lwt.t
  val mpd_banner: c -> string
  val idle: c -> (string -> bool Lwt.t) -> unit Lwt.t
  val send: c -> string -> Protocol.response Lwt.t
  val status: c -> Status.s Lwt.t
  val ping: c -> Protocol.response Lwt.t
  val password: c -> string -> Protocol.response Lwt.t
end = struct
  type c = {connection : LwtConnection.c; mpd_banner : string }

  (** Initialize the client with a connection. *)
  let initialize connection =
    LwtConnection.read_mpd_banner connection
    >>= fun message ->
    Lwt.return {connection = connection; mpd_banner = message}

  (** Close the client *)
  let close client =
    let {connection = connection; _} = client in
    LwtConnection.close connection

 (** Return the mpd banner that the server send at the first connection of the
   client. *)
  let mpd_banner {mpd_banner = banner; _ } =
    banner

  (** Loop on mpd event with the "idle" command
   the on_event function take the event response as argument and return
   true to stop or false to continue the loop *)
  let rec idle client on_event =
    let {connection = connection; _} = client in
    let cmd = "idle\n" in
    LwtConnection.write connection cmd
    >>= fun () ->
      LwtConnection.read_idle_events connection
      >>= fun response ->
        on_event response
        >>=fun stop ->
          match stop with
          | true -> Lwt.return ()
          | false -> idle client on_event

  (** Send to the mpd server a command. The response of the server is returned
   under the form of a Protocol.response type. *)
  let send client cmd =
    let {connection = c; _} = client in
    LwtConnection.write c (cmd ^ "\n")
    >>= fun () ->
      LwtConnection.read_command_response c
      >>= fun response ->
      let parsed_response = Protocol.parse_response response in
        Lwt.return parsed_response

  (** Create a status request and returns the status under a Mpd.Status.s Lwt.t
   type.*)
  let status client =
    send client "status"
    >>= fun response ->
      match response with
      | Ok (lines) -> let status_pairs = Utils.split_lines lines in
      let status = Status.parse status_pairs in Lwt.return status
      | Error (ack, ack_cmd_num, cmd, error) -> let status = Status.generate_error error in
      Lwt.return status

  (** Does nothing but return "OK". *)
  let ping client =
    send client "ping"

  (** This is used for authentication with the server. PASSWORD is simply the
   plaintext password. *)
  let password client mdp =
    send client (String.concat " " ["password"; mdp])
end
