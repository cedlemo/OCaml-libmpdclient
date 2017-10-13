(*
 * Copyright 2017 Cedric LE MOIGNE, cedlemo@gmx.com
 * This file is part of OCaml-libmpdclient.
 *
 * OCaml-libmpdclient is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * any later version.
 *
 * OCaml-libmpdclient is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with OCaml-libmpdclient.  If not, see <http://www.gnu.org/licenses/>.
 *)

(** Module for Mpd current playlist manipulation in Lwt threads. *)

(** Playlist type *)
type t =
  | PlaylistError of string
  | Playlist of Song.s list

(** Adds the file URI to the playlist (directories add recursively). URI can
    also be a single file. *)
val add:
  LwtClient.c -> string -> Protocol.response option Lwt.t

(** Adds a song to the playlist (non-recursive) and returns the song id.
    URI is always a single file or URL. For example: *)
val addid:
  LwtClient.c -> string -> int -> int Lwt.t

(** Clears the current playlist. *)
val clear:
  LwtClient.c -> Protocol.response option Lwt.t

(** Deletes a song or a set of songs from the playlist. The song or the range
    of songs are identified by the position in the playlist. *)
val delete:
  LwtClient.c -> int -> ?position_end:int -> unit -> Protocol.response option Lwt.t

(** Deletes the song SONGID from the playlist. *)
val deleteid:
  LwtClient.c -> int -> Protocol.response option Lwt.t

(** Moves the song at FROM or range of songs at START:END to TO in
    the playlist. *)
val move:
  LwtClient.c -> int -> ?position_end:int -> int -> unit -> Protocol.response option Lwt.t

(** Moves the song with FROM (songid) to TO (playlist index) in the playlist.
    If TO is negative, it is relative to the current song in the playlist
    (if there is one). *)
val moveid:
  LwtClient.c -> int -> int -> Protocol.response option Lwt.t

(** Get a list of Song.s that represents all the songs in the current
    playlist. *)
val playlist:
  LwtClient.c -> t option Lwt.t

(** Get a list with the Song.s of the song id in the playlist *)
val playlistid:
  LwtClient.c -> int -> t option Lwt.t

(** Finds songs in the current playlist with strict matching.*)
val playlistfind:
  LwtClient.c -> string -> string -> t option Lwt.t

(** Searches case-insensitively for partial matches in the current playlist. *)
val playlistsearch:
  LwtClient.c -> string -> string -> t option Lwt.t

(** Swaps the positions of SONG1 and SONG2. *)
val swap:
  LwtClient.c -> int -> int -> Protocol.response option Lwt.t

(** Shuffles the current playlist. START:END is optional and specifies a range
    of songs. *)
val shuffle:
  LwtClient.c -> ?range:(int * int) -> unit -> Protocol.response option Lwt.t

(** Set the priority of the specified songs. A higher priority means that it
    will be played first when "random" mode is enabled.
    A priority is an integer between 0 and 255. The default priority of new
    songs is 0. *)
val prio:
  LwtClient.c -> int -> ?range:(int * int) -> unit -> Protocol.response option Lwt.t

(** Same as prio, but address the songs with their id. *)
val prioid: LwtClient.c -> int -> int list -> Protocol.response option Lwt.t

(** Swaps the positions of SONG1 and SONG2 (both song ids). *)
val swapid: LwtClient.c -> int -> int -> Protocol.response option Lwt.t

(** Specifies the portion of the song that shall be played. START and END are
  offsets in seconds (fractional seconds allowed); both are optional. Omitting
  both (i.e. sending just ":") means "remove the range, play everything". A song
  that is currently playing cannot be manipulated this way. *)
val rangeid:
  LwtClient.c -> int -> ?range:(float * float) -> unit -> Protocol.response option Lwt.t

(** Removes tags from the specified song. If TAG is not specified, then all tag
    values will be removed. Editing song tags is only possible for remote songs.
*)
val cleartagid:
  LwtClient.c -> int -> string -> Protocol.response option Lwt.t
