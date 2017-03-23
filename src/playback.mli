(** Controlling playback functions.
 * https://www.musicpd.org/doc/protocol/playback_commands.html *)

(** Plays next song in the playlist. *)
val next: Mpd.Client.c -> Protocol.response
(** Plays previous song in the playlist. *)
val prev: Mpd.Client.c -> Protocol.response
(** Stops playing.*)
val stop: Mpd.Client.c -> Protocol.response
(** Toggles pause/resumers playing *)
val pause: Mpd.Client.c -> bool -> Protocol.response
(** Begins playing the playlist at song number. *)
val play: Mpd.Client.c -> int -> Protocol.response
(** Begins playing the playlist at song id. *)
val playid: Mpd.Client.c -> int -> Protocol.response
(** Seeks to the position time of entry songpos in the playlist. *)
val seek: Mpd.Client.c -> int -> float -> Protocol.response
(** Seeks to the position time of song id. *)
val seekid: Mpd.Client.c -> int -> float -> Protocol.response
(** Seeks to the position time within the current song.
 * TODO : If prefixed by '+' or '-', then the time is relative to the current
 * playing position
 * *)
val seekcur: Mpd.Client.c -> float -> Protocol.response
