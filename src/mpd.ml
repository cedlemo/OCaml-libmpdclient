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

module Status : sig
  type s
  type state

  val empty : s
  val parse: string list -> s
  val volume: s -> int
  val repeat: s -> bool
  val random: s -> bool
  val single: s -> bool
  val consume: s -> bool
  val playlist: s -> int
  val playlistlength: s -> int
  val state: s -> state
  val song: s -> int
  val songid: s -> int
  val nextsong: s -> int
  val nextsongid: s -> int
  val time: s -> string
  val elapsed: s -> float
  val duration: s -> float
  val bitrate: s -> int
  val xfade: s -> int
  val mixrampdb: s -> float
  val mixrampdelay: s -> int
  val audio: s -> string
  val updating_db: s -> int
  val error: s -> string
end = struct
  type state = Play | Pause | Stop | ErrState

  let state_of_string str =
    match str with
    | "play" -> Play
    | "pause" -> Pause
    | "stop" -> Stop
    | _ -> ErrState

  type s =
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
    time: string; (** total time elapsed (of current playing/paused song) *)
    elapsed: float; (** Total time elapsed within the current song, but with higher resolution. *)
    duration: float; (** Duration of the current song in seconds. *)
    bitrate: int; (** instantaneous bitrate in kbps. *)
    xfade: int; (** crossfade in seconds *)
    mixrampdb: float; (** mixramp threshold in dB *)
    mixrampdelay: int; (** mixrampdelay in seconds *)
    audio: string; (** sampleRate:bits:channels TODO : Maybe create a specific type later *)
    updating_db: int; (** job id *)
    error: string; (** If there is an error, returns message here *)
  }

  let empty =
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
      time = "";
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

  let bool_of_int_str b =
    match b with
    | "0" -> false
    | _   -> true

  type pair = { key : string; value : string }

  let read_key_val str =
    let pattern = Str.regexp ": " in
    let two_str_list = Str.bounded_split pattern str 2 in
    let v =  List.hd (List.rev two_str_list) in
    {key = List.hd two_str_list; value = v}

  (** Parse list of strings into a Mpd Status type *)
  let parse lines =
    let rec _parse pairs s =
      match pairs with
      | [] -> s
      | p :: remain -> let { key = k; value = v} = read_key_val p in
      match k with
        | "volume" -> _parse remain { s with volume = int_of_string v }
        | "repeat" -> _parse remain { s with repeat = bool_of_int_str v }
        | "random" -> _parse remain { s with random = bool_of_int_str v }
        | "single" -> _parse remain { s with single = bool_of_int_str v }
        | "consume" -> _parse remain { s with consume = bool_of_int_str v }
        | "playlist" -> _parse remain { s with playlist = int_of_string v }
        | "playlistlength" -> _parse remain { s with playlistlength = int_of_string v }
        | "state" -> _parse remain { s with state = state_of_string v }
        | "song" -> _parse remain { s with song = int_of_string v }
        | "songid" -> _parse remain { s with songid = int_of_string v }
        | "nextsong" -> _parse remain { s with nextsong = int_of_string v }
        | "nextsongid" -> _parse remain { s with nextsongid = int_of_string v }
        | "time" -> _parse remain { s with time = v } (* TODO: !! mpd time format min:sec*)
        | "elapsed" -> _parse remain { s with elapsed = float_of_string v }
        | "duration" -> _parse remain { s with duration = float_of_string v }
        | "bitrate" -> _parse remain { s with bitrate = int_of_string v }
        | "xfade" -> _parse remain { s with xfade = int_of_string v }
        | "mixrampdb" -> _parse remain { s with mixrampdb = float_of_string v }
        | "mixrampdelay" -> _parse remain { s with mixrampdelay = int_of_string v }
        | "audio" -> _parse remain { s with audio = v }
        | "updating_db" -> _parse remain { s with updating_db = int_of_string v }
        | "error" -> _parse remain { s with error = v }
        | _ -> _parse remain s
      in _parse lines empty
  (** Get the volume level from a Mpd Status *)
  let volume {volume = v; _} =
    v
  (** Find out if the player is in repeat mode *)
  let repeat {repeat = r; _} =
    r
  (** Find out if the player is in random mode *)
  let random {random = r; _} =
    r
  (** Find out if the player is in single mode *)
  let single {single = s; _} =
    s
  (** Find out if the player is in consume mode *)
  let consume {consume = c; _} =
    c
  (** Get the current playlist id *)
  let playlist {playlist = p; _} =
    p
  (** Get the current playlist length *)
  let playlistlength {playlistlength = p; _} =
    p
  (** Get the state of the player : Play / Pause / Stop *)
  let state {state = s; _} =
    s
  (** Get the song number of the current song stopped on or playing *)
  let song {song = s; _} =
    s
  (** Get the song id of the current song stopped on or playing *)
  let songid {songid = s; _} =
    s
  (** Get the next song number based on the current song stopped on or playing *)
  let nextsong {nextsong = n; _} =
    n
  (** Get the next song id based on the current song stopped on or playing *)
  let nextsongid {nextsongid = n; _} =
    n
  (** Get the total time elapsed (of current playing/paused song) *)
  let time {time = t; _} =
    t
  (** Get the total time elapsed within the current song, but with higher resolution *)
  let elapsed {elapsed = e; _} =
    e
  (** Returns the totatl duration of the current song in seconds *)
  let duration {duration = d; _} =
    d
  (** Get the instantaneous bitrate in kbps *)
  let bitrate {bitrate = b; _} =
    b
  (** Get the crossfade in seconds of the current song *)
  let xfade {xfade = x; _} =
    x
  (** Get the mixramp threshold in dB *)
  let mixrampdb {mixrampdb = m; _} =
    m
  (** Get the mixrampdelay in seconds *)
  let mixrampdelay {mixrampdelay = m; _} =
    m
  (** Get information of the audio file of the current song (sampleRate:bits:channels) *)
  let audio {audio = a; _} =
    a
  (** Get the job id *)
  let updating_db {updating_db = u; _} =
    u
  (** Get the error message if there is one *)
  let error {error = e; _} =
    e
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
    Client.write c (String.concat ["play "; string_of_int songpos]);
    let response = Client.read c in
    Protocol.parse_response response

  (** Begins playing the playlist at song id. *)
  let playid c songid =
    Client.write c (String.concat ["playid "; string_of_int songpos]);
    let response = Client.read c in
    Protocol.parse_response response

  (** Seeks to the position time of entry songpos in the playlist. *)
  let seek c songpos time =
    Client.write c (String.concat ["seek ";
                                   string_of_int songpos;
                                   " ";
                                   string_of_float time]);
    let response = Client.read c in
    Protocol.parse_response response

  (** Seeks to the position time of song id. *)
  let seekid c songid time =
    Client.write c (String.concat ["seekid ";
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
    Client.write c (String.concat ["seekcur "; string_of_float time]);
    let response = Client.read c in
    Protocol.parse_response response
end

(* https://www.musicpd.org/doc/protocol/queue.html *)
module Playlist : sig

end = struct

end
