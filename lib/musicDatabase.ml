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

type tags =
  | Unknown
  | Artist
  | Album
  | Album_artist
  | Title
  | Track
  | Name
  | Genre
  | Date
  | Composer
  | Performer
  | Comment
  | Disc
  | Musicbrainz_artistid
  | Musicbrainz_albumid
  | Musicbrainz_albumartistid
  | Musicbrainz_trackid
  | Musicbrainz_releasetrackid
  | Original_date
  | Artist_sort
  | Album_artist_sort
  | Album_sort
  | Count

let tag_to_string = function
  | Unknown -> "unknown"
  | Artist -> "artist"
  | Album -> "album"
  | Album_artist -> "album_artist"
  | Title -> "title"
  | Track -> "track"
  | Name -> "name"
  | Genre -> "genre"
  | Date -> "date"
  | Composer -> "composer"
  | Performer -> "performer"
  | Comment -> "comment"
  | Disc -> "disc"
  | Musicbrainz_artistid -> "musicbrainz_artistid"
  | Musicbrainz_albumid -> "musicbrainz_albumid"
  | Musicbrainz_albumartistid -> "musicbrainz_albumartistid"
  | Musicbrainz_trackid -> "musicbrainz_trackid"
  | Musicbrainz_releasetrackid -> "musicbrainz_releasetrackid"
  | Original_date -> "original_date"
  | Artist_sort -> "artist_sort"
  | Album_artist_sort -> "album_artist_sort"
  | Album_sort -> "album_sort"
  | Count -> "count"

let update client uri =
  let cmd = match uri with
  | None -> "update"
  | Some uri' -> "update " ^ uri'
  in Client.send client cmd

let rescan client uri =
  let cmd = match uri with
  | None -> "rescan"
  | Some uri' -> "rescan " ^ uri'
  in Client.send client cmd
