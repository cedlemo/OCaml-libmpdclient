(* https://www.musicpd.org/doc/protocol/queue.html *)
(* info: unit -> Playlist.p *) (* return current playlist information command is "playlistinfo"*)
type p = | PlaylistError of string | Playlist of Song.s list

(** Adds the file URI to the playlist (directories add recursively). URI can also be a single file. *)
val add: Mpd.Client.c -> string -> Protocol.response
val addid: Mpd.Client.c -> string -> int -> int
(** Clears the current playlist. *)
val clear: Mpd.Client.c -> Protocol.response
(** Deletes a song or a set of songs from the playlist. The song or the range
 * of songs are identified by the position in the playlist. *)
val delete: Mpd.Client.c -> int -> ?position_end:int -> unit -> Protocol.response
(** Deletes the song SONGID from the playlist. *)
val deleteid: Mpd.Client.c -> int -> Protocol.response
(** Moves the song at FROM or range of songs at START:END to TO in
 * the playlist. *)
val move: Mpd.Client.c -> int -> ?position_end:int -> int -> unit -> Protocol.response
(** Moves the song with FROM (songid) to TO (playlist index) in the playlist.
 * If TO is negative, it is relative to the current song in the playlist
 * (if there is one). *)
val moveid: Mpd.Client.c -> int -> int -> Protocol.response
val playlist: Mpd.Client.c -> p

