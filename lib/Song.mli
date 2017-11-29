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

(** Song module used to store and retrieve information of a song based on
 * mpd tags. *)

(** Song type *)
type t

(** Empty song type *)
val empty: t

(** Parse a list of song attributes to a Song.s type *)
val parse: string list -> t

val album: t -> string
val albumsort: t -> string
val albumartist: t -> string
val albumartistsort: t -> string
val artist: t -> string
val artistsort: t -> string
val comment: t -> string
val composer: t -> string
val date: t -> string
val disc: t -> string
val duration: t -> float
val file: t -> string
val genre: t -> string
val id: t -> int
val last_modified: t -> string
val name: t -> string
val performer: t -> string
val pos: t -> int
val rate:  t -> int
val time: t -> int
val title: t -> string
val track: t -> string

(*
TAG_MUSICBRAINZ_ARTISTID
TAG_MUSICBRAINZ_ALBUMID
TAG_MUSICBRAINZ_ALBUMARTISTID
TAG_MUSICBRAINZ_TRACKID
TAG_MUSICBRAINZ_RELEASETRACKID
TAG_NUM_OF_ITEM_TYPES  *)
