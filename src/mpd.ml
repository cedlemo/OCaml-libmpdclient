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
open Sys
open Unix
open Protocol
open Mpd_status

(* TODO create Connection function that takes a host and a port
 * send_command
 * read_result
 *
 * TODO create a Client connection that takes a connection
 * mpd client api *)

(** Libmpd client main module *)

(** Connection module :
   Offer functions in order to handle connections to the mpd server at the
   socket level *)
module Connection : sig
  type c

  val initialize : string -> int -> c
  val close : c -> unit
  val socket: c -> Unix.file_descr
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
end

module Status = struct
  include Mpd_status
end

module Client : sig
  val write: Connection.c -> string -> unit
  val read: Connection.c -> string
  val read_lines: Connection.c -> string list
  val status: Connection.c -> Status.s
end = struct

  (** Write to an Mpd connection *)
  let write c str =
    let socket = Connection.socket c in
    let len = String.length str in
    ignore(send socket str 0 len [])

  (** Read in an Mpd connection *)
  let read c =
    let socket = Connection.socket c in
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
  let read_lines c =
    let response = read c in
    Str.split (Str.regexp "\n") response

  let status c =
    let _ = write c "status\n" in
    let status_pairs = read_lines c in
    Status.parse status_pairs
end

(** Controlling playback :
  * https://www.musicpd.org/doc/protocol/playback_commands.html *)
module Playback : sig
  val next: Connection.c -> Protocol.response
  val prev: Connection.c -> Protocol.response
  val stop: Connection.c -> Protocol.response
  val pause: Connection.c -> bool -> Protocol.response
  val play: Connection.c -> int -> Protocol.response
  val playid: Connection.c -> int -> Protocol.response
  val seek: Connection.c -> int -> float -> Protocol.response
  val seekid: Connection.c -> int -> float -> Protocol.response
end = struct

  (** Plays next song in the playlist. *)
  let next c =
    Client.write c "next";
    let response = Client.read c in
    Protocol.parse_response response

  (** Plays previous song in the playlist. *)
  let prev c =
    Client.write c "prev";
    let response = Client.read c in
    Protocol.parse_response response

  (** Stops playing.*)
  let stop c =
    Client.write c "stop";
    let response = Client.read c in
    Protocol.parse_response response

  (** Toggles pause/resumers playing *)
  let pause c arg =
    let _ = match arg with
    | true -> Client.write c "pause 1"
    | _    -> Client.write c "pause 2"
    in let response = Client.read c in
    Protocol.parse_response response

  (** Begins playing the playlist at song number. *)
  let play c songpos =
    Client.write c (String.concat "" ["play "; string_of_int songpos]);
    let response = Client.read c in
    Protocol.parse_response response

  (** Begins playing the playlist at song id. *)
  let playid c songid =
    Client.write c (String.concat "" ["playid "; string_of_int songid]);
    let response = Client.read c in
    Protocol.parse_response response

  (** Seeks to the position time of entry songpos in the playlist. *)
  let seek c songpos time =
    Client.write c (String.concat "" ["seek ";
                                      string_of_int songpos;
                                      " ";
                                      string_of_float time]);
    let response = Client.read c in
    Protocol.parse_response response

  (** Seeks to the position time of song id. *)
  let seekid c songid time =
    Client.write c (String.concat "" ["seekid ";
                                      string_of_int songid;
                                      " ";
                                      string_of_float time]);
    let response = Client.read c in
    Protocol.parse_response response

  (** Seeks to the position time within the current song.
   * TODO : If prefixed by '+' or '-', then the time is relative to the current
   * playing position
   * *)
  let seekcur c time =
    Client.write c (String.concat "" ["seekcur "; string_of_float time]);
    let response = Client.read c in
    Protocol.parse_response response
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
