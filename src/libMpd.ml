(*
 * https://www.musicpd.org/doc/protocol/response_syntax.html#failure_response_syntax
 * ACK [error@command_listNum] {current_command} message_text\n
 * *)


(* https://www.musicpd.org/doc/protocol/tags.html
 * https://www.musicpd.org/doc/protocol/command_reference.html#status_commands
 * https://www.musicpd.org/doc/protocol/playback_option_commands.html
 * https://www.musicpd.org/doc/protocol/playback_commands.html
 * https://www.musicpd.org/doc/protocol/queue.html
 * https://www.musicpd.org/doc/protocol/playlist_files.html
 * https://www.musicpd.org/doc/protocol/database.html
 * https://www.musicpd.org/doc/protocol/mount.html
 * https://www.musicpd.org/doc/protocol/stickers.html
 * https://www.musicpd.org/doc/protocol/connection_commands.html
 * https://www.musicpd.org/doc/protocol/output_commands.html
 * https://www.musicpd.org/doc/protocol/reflection_commands.html
 * https://www.musicpd.org/doc/protocol/client_to_client.html
 * *)
(* OK\n
 * ACK [error@command_listNum] {current_command} message_text\n *)
open MpdResponses
open Sys
open Unix

(* TODO create Connection function that takes a host and a port
 * send_command
 * read_result
 *
 * TODO create a Client connection that takes a connection
 * mpd client api *)

module Client : sig
  type connection

  val initialize : string -> int -> connection
  val read : connection -> string
  val write : connection -> string -> unit
  val close : connection -> unit
end = struct
  type connection =
    { hostname : string; port : int; ip : Unix.inet_addr; socket : Unix.file_descr }

  let initialize hostname port =
    let ip = try (Unix.gethostbyname hostname).h_addr_list.(0)
             with Not_found ->
               prerr_endline (hostname ^ ": Host not found");
               exit 2
    in let socket = Unix.socket PF_INET SOCK_STREAM 0
    in let _ = Unix.connect socket (ADDR_INET(ip, port))
    in { hostname = hostname; port = port; ip = ip; socket = socket}

    let write {socket; _} str =
      let len = String.length str in
      ignore(send socket str 0 len [])

    let read {socket; _} =
    let _ = Unix.set_nonblock socket in
    let str = Bytes.create 128 in
    let rec _read s acc =
        try
          let recvlen = Unix.recv s str 0 128 [] in
          let recvstr = String.sub str 0 recvlen in _read s (recvstr :: acc)
        with
        | Unix_error(Unix.EAGAIN, _, _) -> if acc = [] then _read s acc else acc
    in String.concat "" (List.rev (_read socket []))

    let close { socket; _} =
      let _ = Unix.set_nonblock socket
      in Unix.close socket
end
