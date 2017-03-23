(** Plays next song in the playlist. *)
let next client =
  Mpd.Client.send_command client "next"

(** Plays previous song in the playlist. *)
let prev client =
  Mpd.Client.send_command client "prev"

(** Stops playing.*)
let stop client =
  Mpd.Client.send_command client "stop"

(** Toggles pause/resumers playing *)
let pause client arg =
  match arg with
  | true -> Mpd.Client.send_command client "pause 1"
  | _    -> Mpd.Client.send_command client "pause 0"

(** Begins playing the playlist at song number. *)
let play client songpos =
  Mpd.Client.send_command client (String.concat " " ["play";
                                                     string_of_int songpos])

(** Begins playing the playlist at song id. *)
let playid client songid =
  Mpd.Client.send_command client (String.concat " " ["playid";
                                                     string_of_int songid])

(** Seeks to the position time of entry songpos in the playlist. *)
let seek client songpos time =
  Mpd.Client.send_command client (String.concat " " ["seek";
                                                     string_of_int songpos;
                                                     string_of_float time])

(** Seeks to the position time of song id. *)
let seekid client songid time =
  Mpd.Client.send_command client (String.concat " " ["seekid";
                                                     string_of_int songid;
                                                     string_of_float time])

(** Seeks to the position time within the current song.
 * TODO : If prefixed by '+' or '-', then the time is relative to the current
 * playing position
 * *)
let seekcur client time =
  Mpd.Client.send_command client (String.concat " " ["seekcur"; string_of_float time])
