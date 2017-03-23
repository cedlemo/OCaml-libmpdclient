open Mpd_utils

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

let parse lines =
  let rec _parse pairs s =
    match pairs with
    | [] -> s
    | p :: remain -> let { key = k; value = v} = Mpd_utils.read_key_val p in
    match k with
      | "volume" -> _parse remain { s with volume = int_of_string v }
      | "repeat" -> _parse remain { s with repeat = Mpd_utils.bool_of_int_str v }
      | "random" -> _parse remain { s with random = Mpd_utils.bool_of_int_str v }
      | "single" -> _parse remain { s with single = Mpd_utils.bool_of_int_str v }
      | "consume" -> _parse remain { s with consume = Mpd_utils.bool_of_int_str v }
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

let volume {volume = v; _} =
  v

let repeat {repeat = r; _} =
  r

let random {random = r; _} =
  r

let single {single = s; _} =
  s

let consume {consume = c; _} =
  c

let playlist {playlist = p; _} =
  p

let playlistlength {playlistlength = p; _} =
  p

let state {state = s; _} =
  s

let song {song = s; _} =
  s

let songid {songid = s; _} =
  s

let nextsong {nextsong = n; _} =
  n

let nextsongid {nextsongid = n; _} =
  n

let time {time = t; _} =
  t

let elapsed {elapsed = e; _} =
  e

let duration {duration = d; _} =
  d

let bitrate {bitrate = b; _} =
  b

let xfade {xfade = x; _} =
  x

let mixrampdb {mixrampdb = m; _} =
  m

let mixrampdelay {mixrampdelay = m; _} =
  m

let audio {audio = a; _} =
  a

let updating_db {updating_db = u; _} =
  u

let error {error = e; _} =
  e

let generate_error message  =
  {empty with error = message}
