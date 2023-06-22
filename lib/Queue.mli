(*
 * Copyright 2017-2018 Cedric LE MOIGNE, cedlemo@gmx.com
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

(** Module for Mpd current playlist manipulation. *)

type t =
  | PlaylistError of string
  | Playlist of Song.t list  (** Playlist type. *)

val add : Client.t -> string -> Protocol.response
(** Add the file URI to the playlist (directories add recursively). URI can
    also be a single file. *)

val addid : Client.t -> string -> int -> int
(** Add a song to the playlist (non-recursive) and returns the song id.
    URI is always a single file or URL. *)

val clear : Client.t -> Protocol.response
(** Clear the current playlist. *)

val delete : Client.t -> int -> ?position_end:int -> unit -> Protocol.response
(** Delete a song or a set of songs from the playlist. The song or the range
    of songs are identified by the position in the playlist. *)

val deleteid : Client.t -> int -> Protocol.response
(** Delete the song SONGID from the playlist. *)

val move :
  Client.t -> int -> ?position_end:int -> int -> unit -> Protocol.response
(** Move the song at FROM or range of songs at START:END to TO in
    the playlist. *)

val moveid : Client.t -> int -> int -> Protocol.response
(** Move the song with FROM (songid) to TO (playlist index) in the playlist.
    If TO is negative, it is relative to the current song in the playlist
    (if there is one). *)

val playlist : Client.t -> t
(** Get the songs in the playlist *)

val playlistid : Client.t -> int -> (Song.t, string) result
(** Get information for one song *)

val playlistfind : Client.t -> string -> string -> t
(** Find songs in the current playlist with strict matching.*)

val playlistsearch : Client.t -> string -> string -> t
(** Search case-insensitively for partial matches in the current playlist. *)

val swap : Client.t -> int -> int -> Protocol.response
(** Swap the positions of SONG1 and SONG2. *)

val shuffle : Client.t -> ?range:int * int -> unit -> Protocol.response
(** Shuffle the current playlist. START:END is optional and specifies a range
    of songs. *)

val prio : Client.t -> int -> ?range:int * int -> unit -> Protocol.response
(** Set the priority of the specified songs. A higher priority means that it
    will be played first when "random" mode is enabled.
    A priority is an integer between 0 and 255. The default priority of new
    songs is 0. *)

val prioid : Client.t -> int -> int list -> Protocol.response
(** Same as prio, but address the songs with their id. *)

val swapid : Client.t -> int -> int -> Protocol.response
(** Swap the positions of SONG1 and SONG2 (both song ids). *)

val rangeid :
  Client.t -> int -> ?range:float * float -> unit -> Protocol.response
(** Specify the portion of the song that shall be played. START and END are
  offsets in seconds (fractional seconds allowed); both are optional. Omitting
  both (i.e. sending just ":") means "remove the range, play everything". A song
  that is currently playing cannot be manipulated this way. *)

val cleartagid : Client.t -> int -> string -> Protocol.response
(** Remove tags from the specified song. If TAG is not specified, then all tag
    values will be removed. Editing song tags is only possible for remote songs.
*)

(**/**)

(*
  plchanges {VERSION} [START:END]
  plchangesposid {VERSION} [START:END]
  addtagid {SONGID} {TAG} {VALUE}
*)
(**/**)
