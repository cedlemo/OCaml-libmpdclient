(*
 * https://www.musicpd.org/doc/protocol/response_syntax.html#failure_response_syntax
 * ACK [error@command_listNum] {current_command} message_text\n
 * *)


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
(* OK\n
 * ACK [error@command_listNum] {current_command} message_text\n *)
open Sys
open Unix
open Protocol
open Mpd_status
open Mpd_utils

module Utils = struct
  include Mpd_utils
end

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

(** Functions and type needed to store and manipulate an mpd status request
 * information.
 * https://www.musicpd.org/doc/protocol/command_reference.html#status_commands
 *)
module Status = struct
  include Mpd_status
end

(** Functions and type neede to store and manipulate song informations
 * Song format example
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
module Song = struct
  include Mpd_song
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
    | Ok (lines) -> let status_pairs = Utils.split_lines lines in
    Status.parse status_pairs
    | Error (ack, ack_cmd_num, cmd, error) -> Status.generate_error error

  (** Does nothing but return "OK". *)
  let ping client =
    send_command client "ping"

  (** This is used for authentication with the server. PASSWORD is simply the
   * plaintext password. *)
  let password client mdp =
    send_request client (String.concat " " ["password"; mdp])

  (** Shows a list of available tag types. It is an intersection of the
   * metadata_to_use setting and this client's tag mask.
   * About the tag mask: each client can decide to disable any number of tag
   * types, which will be omitted from responses to this client. That is a good
   * idea, because it makes responses smaller. The following tagtypes sub
   * commands configure this list. *)
  let tagtypes client =
    let response = send_request client "tagtypes" in
    match response with
    | Ok (lines) -> let tagid_keys_vals = Utils.split_lines lines in
    List.rev (values_of_pairs tagid_keys_vals)
    | Error (ack, ack_cmd_num, cmd, error) -> []
  (*
  (** Remove one or more tags from the list of tag types the client is
   * interested in. These will be omitted from responses to this client. *)
  let tagtypes_disable client tagtypes =
    send_command client (String.concat "" ["tagtypes disable ";
                                           String.concat " " tagtypes])
  (** Re-enable one or more tags from the list of tag types for this client.
   * These will no longer be hidden from responses to this client. *)
  let tagtypes_enable client tagtypes =
    send_command client (String.concat "" ["tagtypes enable ";
                                           String.concat " " tagtypes])

  (** Clear the list of tag types this client is interested in. This means that
   * MPD will not send any tags to this client. *)
  let tagtypes_clear client =
    send_command client "tagtypes clear"

  (** Announce that this client is interested in all tag types. This is the
   * default setting for new clients. *)
  let tagtypes_all client =
    send_command client "tagtypes all"
   *)

  (** Closes the connection to MPD. MPD will try to send the remaining output
   * buffer before it actually closes the connection, but that cannot be
   * guaranteed. This command will not generate a response. *)
  let close client =
    let {connection = c; _} = client in
    Connection.write c ("close\n");
    Connection.close c;
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
  let next client =
    Client.send_command client "next"

  (** Plays previous song in the playlist. *)
  let prev client =
    Client.send_command client "prev"

  (** Stops playing.*)
  let stop client =
    Client.send_command client "stop"

  (** Toggles pause/resumers playing *)
  let pause client arg =
    match arg with
    | true -> Client.send_command client "pause 1"
    | _    -> Client.send_command client "pause 0"

  (** Begins playing the playlist at song number. *)
  let play client songpos =
    Client.send_command client (String.concat " " ["play"; string_of_int songpos])

  (** Begins playing the playlist at song id. *)
  let playid client songid =
    Client.send_command client (String.concat " " ["playid"; string_of_int songid])

  (** Seeks to the position time of entry songpos in the playlist. *)
  let seek client songpos time =
    Client.send_command client (String.concat " " ["seek";
                                             string_of_int songpos;
                                             string_of_float time])

  (** Seeks to the position time of song id. *)
  let seekid client songid time =
    Client.send_command client (String.concat " " ["seekid";
                                             string_of_int songid;
                                             string_of_float time])

  (** Seeks to the position time within the current song.
   * TODO : If prefixed by '+' or '-', then the time is relative to the current
   * playing position
   * *)
  let seekcur client time =
    Client.send_command client (String.concat " " ["seekcur"; string_of_float time])
end

(* https://www.musicpd.org/doc/protocol/queue.html *)
module CurrentPlaylist : sig
  (* info: unit -> Playlist.p *) (* return current playlist information command is "playlistinfo"*)
  type p = | PlaylistError of string | Playlist of Song.s list

  val add: Client.c -> string -> Protocol.response
  val addid: Client.c -> string -> int -> int
  val clear: Client.c -> Protocol.response
  val delete: Client.c -> int -> ?position_end:int -> unit -> Protocol.response
  val deleteid: Client.c -> int -> Protocol.response
  val move: Client.c -> int -> ?position_end:int -> int -> unit -> Protocol.response
  val moveid: Client.c -> int -> int -> Protocol.response
  val playlist: Client.c -> p
end = struct
  type p =
    | PlaylistError of string | Playlist of Song.s list

  (** Adds the file URI to the playlist (directories add recursively). URI can also be a single file. *)
  let add client uri =
    Client.send_command client uri

  let addid client uri position =
    let cmd = String.concat " " ["addid"; uri; string_of_int position] in
    let response = Client.send_command client cmd in
    match response with
    |Ok (song_id) -> let lines = Utils.split_lines song_id in
    let rec parse lines =
      match lines with
        | [] -> -1
        | line :: remain -> let { key = k; value = v} = Utils.read_key_val line in
        if (k = "Id") then int_of_string v
                            else parse remain
        in parse lines
        |Error (_) -> -1

  (** Clears the current playlist. *)
  let clear client =
    Client.send_command client "clear"

  (** Deletes a song or a set of songs from the playlist. The song or the range
   * of songs are identified by the position in the playlist. *)
  let delete client position ?position_end () =
    let cmd = match position_end with
    |None -> String.concat " " ["delete"; string_of_int position]
    |Some pos_end -> String.concat "" ["delete ";
                                       string_of_int position;
                                       ":";
                                       string_of_int pos_end]
  in Client.send_command client cmd

  (** Deletes the song SONGID from the playlist. *)
  let deleteid client id =
    Client.send_command client (String.concat " " ["deleteid"; string_of_int id])

  (** Moves the song at FROM or range of songs at START:END to TO in
   * the playlist. *)
  let move client position_from ?position_end position_to () =
    let cmd = match position_end with
    |None -> String.concat " " ["move";
                                string_of_int position_from;
                                string_of_int position_to]
    |Some pos_end -> String.concat "" ["move ";
                                       string_of_int position_from;
                                       ":";
                                       string_of_int pos_end;
                                       " ";
                                       string_of_int position_to]
  in Client.send_command client cmd

  (** Moves the song with FROM (songid) to TO (playlist index) in the playlist.
   * If TO is negative, it is relative to the current song in the playlist
   * (if there is one). *)
  let moveid client id position_to =
    Client.send_command client (String.concat " " ["moveid";
                                              string_of_int id;
                                              string_of_int position_to])

  let get_song_id song =
    let pattern = "\\([0-9]+\\):file:.*" in
    let found = Str.string_match (Str.regexp pattern) song 0 in
    if found then Str.matched_group 1 song
    else "none"

  let rec _build_songs_list client songs l =
    match songs with
    | [] -> Playlist (List.rev l)
    | h :: q -> let song_infos_request = "playlistinfo " ^ (get_song_id h) in
    match Client.send_request client song_infos_request with
    | Protocol.Error (ack_val, ack_cmd_num, ack_cmd, ack_message)-> PlaylistError (ack_message)
    | Protocol.Ok (song_infos) -> let song = Song.parse (Mpd_utils.split_lines song_infos) in
     _build_songs_list client q (song :: l)

  let playlist client =
    match Client.send_request client "playlist" with
    | Protocol.Error (ack_val, ack_cmd_num, ack_cmd, ack_message)-> PlaylistError (ack_message)
    | Protocol.Ok (response) -> let songs = Mpd_utils.split_lines response in
    _build_songs_list client songs []
end

(* https://www.musicpd.org/doc/protocol/playlist_files.html *)
module Playlists : sig
end = struct
end

