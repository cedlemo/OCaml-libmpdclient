(*
 * Copyright 2017 Cedric LE MOIGNE, cedlemo@gmx.com
 * This file is part of OCaml-libmpdclient.
 *
 * OCaml-GObject-Introspection is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * any later version.
 *
 * OCaml-GObject-Introspection is distributed in the hope that it will be useful,
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
type s

(** Empty song type *)
val empty: s

(** Parse a list of song attributes to a Song.s type *)
val parse: string list -> s

val album: s -> string
val albumsort: s -> string
val albumartist: s -> string
val albumartistsort: s -> string
val artist: s -> string
val artistsort: s -> string
val comment: s -> string
val composer: s -> string
val date: s -> string
val disc: s -> string
val duration: s -> float
val file: s -> string
val genre: s -> string
val id: s -> int
val last_modified: s -> string
val name: s -> string
val performer: s -> string
val pos: s -> int
val rate:  s -> int
val time: s -> int
val title: s -> string
val track: s -> string

(*
TAG_MUSICBRAINZ_ARTISTID
TAG_MUSICBRAINZ_ALBUMID
TAG_MUSICBRAINZ_ALBUMARTISTID
TAG_MUSICBRAINZ_TRACKID
TAG_MUSICBRAINZ_RELEASETRACKID
TAG_NUM_OF_ITEM_TYPES  *)
