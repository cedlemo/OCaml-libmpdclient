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

(** StoredPlaylists : Playlists are stored inside the configured playlist
    directory. They are addressed with their file name (without the directory
    and without the .m3u suffix). *)

(* TODO s :
*
* -> listplaylists
*
* Prints a list of the playlist directory.
*
* After each playlist name the server sends its last modification time as
* attribute "Last-Modified" in ISO 8601 format. To avoid problems due to clock
* differences between clients and the server, clients should not compare this
* value with their local clock.
* format :
* playlist: zen
* Last-Modified: 2014-12-02T10:15:57Z
* playlist: rtl
* Last-Modified: 2014-12-02T10:15:57Z
* should be val listplaylists: Mpd.Client.c -> string list
*
* -> load {NAME} [START:END]
*
* Loads the playlist into the current queue. Playlist plugins are supported. A
* range may be specified to load only a part of the playlist.
*  val load: Mpd.Client.c -> string -> ?range:(int * int) -> unit -> Protocol.response
*
*  -> playlistadd {NAME} {URI}
* Adds URI to the playlist NAME.m3u. NAME.m3u will be created if it does not exist.
*
*  val playlistadd: Mpd.Client.c -> string -> string -> Protocol.response
*
*  -> playlistclear {NAME}
*  Clears the playlist NAME.m3u.
*  val playlistclear: Mpd.Client.c -> string -> Protocol.response
*
*  -> playlistdelete {NAME} {SONGPOS}
*  Deletes SONGPOS from the playlist NAME.m3u.
*  val playlistdelete: Mpd.Client.c -> int -> Protocol.response
*
*  -> playlistmove {NAME} {FROM} {TO}
*  Moves the song at position FROM in the playlist NAME.m3u to the position TO.
*  val playlistmove: Mpd.Client.c -> int -> int -> Protocol.response
*
*  -> rename {NAME} {NEW_NAME}
*  Renames the playlist NAME.m3u to NEW_NAME.m3u.
*  val rename: Mpd.Client.c -> string -> string -> Protocol.response
*
*  -> rm {NAME}
*  Removes the playlist NAME.m3u from the playlist directory.
*  val rm: Mpd.Client.c -> string -> Protocol.response
*
*  -> save {NAME}
*  Saves the current playlist to NAME.m3u in the playlist directory.
   val save: Mpd.Client.c -> string -> Protocol.response
*)
