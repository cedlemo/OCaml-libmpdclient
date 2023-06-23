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

open Utils

type t = {
  album : string;
  albumsort : string; (* TODO : int ? *)
  albumartist : string;
  albumartistsort : string; (* TODO : int ? *)
  artist : string;
  artistsort : string; (* TODO : int ? *)
  comment : string;
  composer : string;
  date : string;
  disc : string; (* TODO : num_on_num *)
  duration : float;
  file : string;
  genre : string;
  id : int;
  last_modified : string;
  name : string;
  performer : string;
  pos : int;
  rate : int;
  time : int;
  title : string;
  track : string; (* TODO : num_on_num *)
}

let empty =
  {
    album = "";
    albumsort = "";
    albumartist = "";
    albumartistsort = "";
    artist = "";
    artistsort = "";
    comment = "";
    composer = "";
    date = "";
    disc = "";
    duration = 0.0;
    file = "";
    genre = "";
    id = 0;
    last_modified = "";
    name = "";
    performer = "";
    pos = 0;
    rate = 0;
    time = 0;
    title = "";
    track = "";
  }

let parse lines =
  let rec _parse pairs s =
    match pairs with
    | [] -> s
    | p :: remain -> (
        let { key = k; value = v } = Utils.read_key_val p in
        match k with
        | "Album" -> _parse remain { s with album = v }
        | "AlbumSort" -> _parse remain { s with albumsort = v }
        | "AlbumArtist" -> _parse remain { s with albumartist = v }
        | "AlbumArtistSort" -> _parse remain { s with albumartistsort = v }
        | "Artist" -> _parse remain { s with artist = v }
        | "ArtistSort" -> _parse remain { s with artistsort = v }
        | "Comment" -> _parse remain { s with comment = v }
        | "Composer" -> _parse remain { s with composer = v }
        | "Date" -> _parse remain { s with date = v }
        | "Disc" -> _parse remain { s with disc = v }
        | "duration" -> _parse remain { s with duration = float_of_string v }
        | "Genre" -> _parse remain { s with genre = v }
        | "File" -> _parse remain { s with file = v }
        | "Id" -> _parse remain { s with id = int_of_string v }
        | "Last-Modified" -> _parse remain { s with last_modified = v }
        | "Name" -> _parse remain { s with title = v }
        | "Performer" -> _parse remain { s with performer = v }
        | "Pos" -> _parse remain { s with pos = int_of_string v }
        | "Rate" -> _parse remain { s with rate = int_of_string v }
        | "Time" -> _parse remain { s with time = int_of_string v }
        | "Title" -> _parse remain { s with title = v }
        | "Track" -> _parse remain { s with track = v }
        | _ -> _parse remain s)
  in
  _parse lines empty

let album { album = a; _ } = a
let albumsort { albumsort = a; _ } = a
let albumartist { albumartist = a; _ } = a
let albumartistsort { albumartist = a; _ } = a
let artist { artist = a; _ } = a
let artistsort { artist = a; _ } = a
let comment { comment = c; _ } = c
let composer { composer = c; _ } = c
let date { date = d; _ } = d
let disc { disc = d; _ } = d
let duration { duration = d; _ } = d
let file { file = f; _ } = f
let genre { genre = g; _ } = g
let id { id = i; _ } = i
let last_modified { last_modified = l; _ } = l
let name { name = n; _ } = n
let performer { performer = p; _ } = p
let pos { pos = p; _ } = p
let rate { rate = r; _ } = r
let time { time = t; _ } = t
let title { title = t; _ } = t
let track { track = t; _ } = t
