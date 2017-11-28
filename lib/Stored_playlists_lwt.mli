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

(** LwtStoredPlaylists : Playlists are stored inside the configured playlist
    directory. They are addressed with their file name (without the directory
    and without the .m3u suffix). This is module is based on Lwt. *)

(** Prints a list of the playlist names. *)
val listplaylists:
  Client_lwt.t -> string list option Lwt.t

(** Loads the playlist into the current queue. Playlist plugins are supported.
    A range may be specified to load only a part of the playlist. *)
val load:
  Client_lwt.t -> string -> ?range:(int * int) -> unit -> Protocol.response Lwt.t

(** Adds URI to the playlist NAME.m3u. NAME.m3u will be created if it does not
    exist. *)
val playlistadd:
  Client_lwt.t -> string -> string -> Protocol.response Lwt.t

(** Clears the playlist NAME.m3u. *)
val playlistclear:
  Client_lwt.t -> string -> Protocol.response Lwt.t

(** Deletes SONGPOS from the playlist NAME.m3u. *)
val playlistdelete:
  Client_lwt.t -> string -> int -> Protocol.response Lwt.t

(** Moves the song at position FROM in the playlist NAME.m3u to the position TO. *)
val playlistmove:
  Client_lwt.t -> string -> int -> int -> Protocol.response Lwt.t

(** Renames the playlist NAME.m3u to NEW_NAME.m3u. *)
val rename:
  Client_lwt.t -> string -> string -> Protocol.response Lwt.t

(** Removes the playlist NAME.m3u from the playlist directory. *)
val rm:
  Client_lwt.t -> string -> Protocol.response Lwt.t

(** Saves the current playlist to NAME.m3u in the playlist directory. *)
val save:
  Client_lwt.t -> string -> Protocol.response Lwt.t
