(** Current state of the mpd server. *)
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
(** Build a status error message. When the status request return an error, this
 * function is useful to generate an empty status with the error message set. *)
let generate_error message  =
  {empty with error = message}
