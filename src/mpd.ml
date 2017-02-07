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
open Protocol
open Sys
open Unix

(* TODO create Connection function that takes a host and a port
 * send_command
 * read_result
 *
 * TODO create a Client connection that takes a connection
 * mpd client api *)

(** Libmpd client main module *)

(** Connection module :
   Offers functions in order to handle connections to the mpd server at the
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

  (** Create the connection, exist is the connection can not be initialized. *)
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

module Client : sig
  type status_type
  val write: Connection.c -> string -> unit
  val read: Connection.c -> string
  val read_lines: Connection.c -> string list
  val status: Connection.c -> status_type
  val volume: status_type -> int
  val bool_of_int_str: string -> bool
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

  type pair = { key : string; value : string }

  let read_key_val str =
    let pattern = Str.regexp ": " in
    let two_str_list = Str.bounded_split pattern str 2 in
    let v =  List.hd (List.rev two_str_list) in
    {key = List.hd two_str_list; value = v}

  type state = Play | Pause | Stop | ErrState

  let state_of_string str =
    match str with
    | "play" -> Play
    | "pause" -> Pause
    | "stop" -> Stop
    | _ -> ErrState

  type status_type =
  { volume: int; (** 0-100 *)
    repeat: bool; (** false or true *)
    random: bool; (** false or true *)
    single: bool; (** false or true *)
    consume: bool; (** false or true *)
    playlist: int; (** 31-bit unsigned integer, the playlist version number *)
    playlistlength: int; (** the length of the playlist *)
    state: state; (** play, stop, or pause *)
    song: int; (** playlist song number of the current song stopped on or playing *)
    songid: int; (** playlist songid of the current song stopped on or playing *)
    nextsong: int; (** playlist song number of the next song to be played *)
    nextsongid: int; (** playlist songid of the next song to be played *)
    time: float; (** total time elapsed (of current playing/paused song) *)
    elapsed: float; (** Total time elapsed within the current song, but with higher resolution. *)
    duration: float; (** Duration of the current song in seconds. *)
    bitrate: int; (** instantaneous bitrate in kbps. *)
    xfade: int; (** crossfade in seconds *)
    mixrampdb: float; (** mixramp threshold in dB *)
    mixrampdelay: int; (** mixrampdelay in seconds *)
    audio: string; (** sampleRate:bits:channels TODO : Maybe create a specific type later *)
    updating_db: int; (** job id *)
    error: string; (** there is an error, returns message here *)
  }
  let bool_of_int_str b =
    match b with
    | "0" -> false
    | _   -> true

  let status c =
    let _ = write c "status\n" in
    let status_pairs = read_lines c in
    let rec parse pairs s =
      match pairs with
      | [] -> s
      | p :: remain -> let { key = k; value = v} = read_key_val p in
      match k with
        | "volume" -> parse remain { s with volume = int_of_string v }
        | "repeat" -> parse remain { s with repeat = bool_of_int_str v }
        | "random" -> parse remain { s with random = bool_of_int_str v }
        | "single" -> parse remain { s with single = bool_of_int_str v }
        | "consume" -> parse remain { s with consume = bool_of_int_str v }
        | "playlist" -> parse remain { s with playlist = int_of_string v }
        | "playlistlength" -> parse remain { s with playlistlength = int_of_string v }
        | "state" -> parse remain { s with state = state_of_string v }
        | "song" -> parse remain { s with song = int_of_string v }
        | "songid" -> parse remain { s with songid = int_of_string v }
        | "nextsong" -> parse remain { s with nextsong = int_of_string v }
        | "nextsongid" -> parse remain { s with nextsongid = int_of_string v }
        | "time" -> parse remain { s with time = float_of_string v }
        | "elapsed" -> parse remain { s with elapsed = float_of_string v }
        | "duration" -> parse remain { s with duration = float_of_string v }
        | "bitrate" -> parse remain { s with bitrate = int_of_string v }
        | "xfade" -> parse remain { s with xfade = int_of_string v }
        | "mixrampdb" -> parse remain { s with mixrampdb = float_of_string v }
        | "mixrampdelay" -> parse remain { s with mixrampdelay = int_of_string v }
        | "audio" -> parse remain { s with audio = v }
        | "updating_db" -> parse remain { s with updating_db = int_of_string v }
        | "error" -> parse remain { s with error = v }
        | _ -> parse remain s
      in let initial_status =
        {
          volume = 0;
          repeat = false;
          random = false;
          single = false;
          consume = false;
          playlist = 0;
          playlistlength = 0;
          state = Stop;
          song = 0;
          songid = 0;
          nextsong = 0;
          nextsongid = 0;
          time = 0.0;
          elapsed = 0.0;
          duration = 0.0;
          bitrate = 0;
          xfade = 0;
          mixrampdb = 0.0;
          mixrampdelay = 0;
          audio = "";
          updating_db = 0;
          error = "";
        }
      in parse status_pairs initial_status

  let volume {volume = v; _} =
   v

end
