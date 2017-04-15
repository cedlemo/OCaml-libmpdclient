(*
 * Copyright 2017 Cedric LE MOIGNE, cedlemo@gmx.com
 * This file is part of OCaml-libmpdclient.
 *
 * Topinambour is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * any later version.
 *
 * Topinambour is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with OCaml-libmpdclient.  If not, see <http://www.gnu.org/licenses/>.
 *)

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
(** Get the songs in the playlist *)
val playlist: Mpd.Client.c -> p
(** Get information for one song *)
val playlistid: Mpd.Client.c -> int -> p
(*
playlistfind {TAG} {NEEDLE}

Finds songs in the current playlist with strict matching.

playlistinfo [[SONGPOS] | [START:END]]

Displays a list of all songs in the playlist, or if the optional argument is given, displays information only for the song SONGPOS or the range of songs START:END [6]

playlistsearch {TAG} {NEEDLE}

Searches case-insensitively for partial matches in the current playlist.

plchanges {VERSION} [START:END]

Displays changed songs currently in the playlist since VERSION. Start and end positions may be given to limit the output to changes in the given range.

To detect songs that were deleted at the end of the playlist, use playlistlength returned by status command.

plchangesposid {VERSION} [START:END]

Displays changed songs currently in the playlist since VERSION. This function only returns the position and the id of the changed song, not the complete metadata. This is more bandwidth efficient.

To detect songs that were deleted at the end of the playlist, use playlistlength returned by status command.

prio {PRIORITY} {START:END...}

Set the priority of the specified songs. A higher priority means that it will be played first when "random" mode is enabled.

A priority is an integer between 0 and 255. The default priority of new songs is 0.

prioid {PRIORITY} {ID...}

Same as prio, but address the songs with their id.

rangeid {ID} {START:END}

[7] Specifies the portion of the song that shall be played. START and END are offsets in seconds (fractional seconds allowed); both are optional. Omitting both (i.e. sending just ":") means "remove the range, play everything". A song that is currently playing cannot be manipulated this way.

shuffle [START:END]

Shuffles the current playlist. START:END is optional and specifies a range of songs.

swap {SONG1} {SONG2}

Swaps the positions of SONG1 and SONG2.

swapid {SONG1} {SONG2}

Swaps the positions of SONG1 and SONG2 (both song ids).

addtagid {SONGID} {TAG} {VALUE}

Adds a tag to the specified song. Editing song tags is only possible for remote songs. This change is volatile: it may be overwritten by tags received from the server, and the data is gone when the song gets removed from the queue.

cleartagid {SONGID} [TAG]

Removes tags from the specified song. If TAG is not specified, then all tag values will be removed. Editing song tags is only possible for remote songs.
*)
