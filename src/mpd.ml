(*
 * https://www.musicpd.org/doc/protocol/response_syntax.html#failure_response_syntax
 * ACK [error@command_listNum] {current_command} message_text\n
 * *)


(* https://www.musicpd.org/doc/protocol/tags.html
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
open Sys
open Unix
open Protocol
open Mpd_status

(** Libmpd client main module *)

(** Offer functions and type in order to handle connections to the mpd server at
   the socket level *)
module Connection : sig
  type c

  val initialize : string -> int -> c
  val close : c -> unit
  val socket: c -> Unix.file_descr
  val write: c -> string -> unit
  val read: c -> string
  val read_lines: string -> string list
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

  (** Read an Mpd response and returns a list of strings *)
  let read_lines response =
    Str.split (Str.regexp "\n") response
end

(** Functions and type needed to store and manipulate an mpd status request
  * information.
  * https://www.musicpd.org/doc/protocol/command_reference.html#status_commands
  *)
module Status = struct
  include Mpd_status
end

(** Provides functions and type in order to communicate to the mpd server
  * with commands and requests. *)
module Client : sig
  type c

  val initialize: Connection.c -> c
  val send_command: c -> string -> Protocol.response
  val send_request: c -> string -> Protocol.response
  val mpd_banner: c -> string
  val status: c -> Status.s

end = struct
  (** Client type *)
  type c = {connection : Connection.c; mpd_banner : string }

  (** Initialize the client with a connection. *)
  let initialize connection =
    let message = Connection.read connection in
    {connection = connection; mpd_banner = message}

  (** Send to the mpd server a command. The response of the server is returned
   * under the form of a Protocol.response type. *)
  let send_command client cmd =
    let {connection = c; _} = client in
    Connection.write c (cmd ^ "\n");
    let response = Connection.read c in
    Protocol.parse_response response

  (** Send to the mpd server a request. The response of the server is returned
   * under the form of a Protocol.response type. *)
  let send_request client request =
    let {connection = c; _} = client in
    Connection.write c (request ^ "\n");
    let response = Connection.read c in
    Protocol.parse_response response

  (** Return the mpd banner that the server send at the first connection of the
   * client. *)
  let mpd_banner {mpd_banner = banner; _ } =
    banner

  (** Create a status request and returns the status under a Mpd.Status.s
   * type.*)
  let status client =
    let response = send_request client "status" in
    match response with
    | Ok (lines) -> let status_pairs = Connection.read_lines lines in
                    Status.parse status_pairs
    | Error (ack, ack_cmd_num, cmd, error) -> Status.generate_error error
end

(** Controlling playback functions.
  * https://www.musicpd.org/doc/protocol/playback_commands.html *)
module Playback : sig
  val next: Client.c -> Protocol.response
  val prev: Client.c -> Protocol.response
  val stop: Client.c -> Protocol.response
  val pause: Client.c -> bool -> Protocol.response
  val play: Client.c -> int -> Protocol.response
  val playid: Client.c -> int -> Protocol.response
  val seek: Client.c -> int -> float -> Protocol.response
  val seekid: Client.c -> int -> float -> Protocol.response
end = struct

  (** Plays next song in the playlist. *)
  let next c =
    Client.send_command c "next"

  (** Plays previous song in the playlist. *)
  let prev c =
    Client.send_command c "prev"

  (** Stops playing.*)
  let stop c =
    Client.send_command c "stop"

  (** Toggles pause/resumers playing *)
  let pause c arg =
    match arg with
    | true -> Client.send_command c "pause 1"
    | _    -> Client.send_command c "pause 2"

  (** Begins playing the playlist at song number. *)
  let play c songpos =
    Client.send_command c (String.concat "" ["play "; string_of_int songpos])

  (** Begins playing the playlist at song id. *)
  let playid c songid =
    Client.send_command c (String.concat "" ["playid "; string_of_int songid])

  (** Seeks to the position time of entry songpos in the playlist. *)
  let seek c songpos time =
    Client.send_command c (String.concat "" ["seek ";
                                             string_of_int songpos;
                                             " ";
                                             string_of_float time])

  (** Seeks to the position time of song id. *)
  let seekid c songid time =
    Client.send_command c (String.concat "" ["seekid ";
                                             string_of_int songid;
                                             " ";
                                             string_of_float time])

  (** Seeks to the position time within the current song.
   * TODO : If prefixed by '+' or '-', then the time is relative to the current
   * playing position
   * *)
  let seekcur c time =
    Client.send_command c (String.concat "" ["seekcur "; string_of_float time])
end

(* https://www.musicpd.org/doc/protocol/queue.html *)
module Playlist : sig
(* info: unit -> Playlist.p *) (* return current playlist information command is "playlistinfo"*)
end = struct

end

(* Song format example
 * file: Nile - What Should Not Be Unearthed (2015)/02 Negating The Abominable Coils Of Apep.mp3.mp3
 * Last-Modified: 2015-08-13T09:56:32Z
 * artist: Nile
 * title: Negating The Abominable Coils Of Apep
 * album: What Should Not Be Unearthed
 * track: 2
 * rate: 2015
 * genre: Death Metal
 * time: 254
 * duration: 254.093
 * pos: 1
 * id: 2
*)
