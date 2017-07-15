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
  Mpd.LwtClient.c -> string list option Lwt.t

(** Loads the playlist into the current queue. Playlist plugins are supported.
    A range may be specified to load only a part of the playlist. *)
val load:
  Mpd.LwtClient.c -> string -> ?range:(int * int) -> unit -> Protocol.response Lwt.t

(** Adds URI to the playlist NAME.m3u. NAME.m3u will be created if it does not
    exist. *)
val playlistadd:
  Mpd.LwtClient.c -> string -> string -> Protocol.response Lwt.t


