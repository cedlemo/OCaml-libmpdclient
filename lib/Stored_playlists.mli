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

(** Stored_playlists : Playlists are stored inside the configured playlist
    directory. They are addressed with their file name (without the directory
    and without the .m3u suffix). *)

val listplaylists : Client.t -> (string list, string) result
(** Print a list of the playlist names. *)

val load : Client.t -> string -> ?range:int * int -> unit -> Protocol.response
(** Load the playlist into the current queue. Playlist plugins are supported.
    A range may be specified to load only a part of the playlist. *)

val playlistadd : Client.t -> string -> string -> Protocol.response
(** Add URI to the playlist NAME.m3u. NAME.m3u will be created if it does not
    exist. *)

val playlistclear : Client.t -> string -> Protocol.response
(** Clear the playlist NAME.m3u. *)

val playlistdelete : Client.t -> string -> int -> Protocol.response
(** Delete SONGPOS from the playlist NAME.m3u. *)

val playlistmove : Client.t -> string -> int -> int -> Protocol.response
(** Move the song at position FROM in the playlist NAME.m3u to the position TO. *)

val rename : Client.t -> string -> string -> Protocol.response
(** Rename the playlist NAME.m3u to NEW_NAME.m3u. *)

val rm : Client.t -> string -> Protocol.response
(** Remove the playlist NAME.m3u from the playlist directory. *)

val save : Client.t -> string -> Protocol.response
(** Save the current playlist to NAME.m3u in the playlist directory. *)
