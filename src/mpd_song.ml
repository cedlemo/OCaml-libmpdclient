open Mpd_utils
type s = {
  album: string;
  albumsort: string; (* TODO : int ? *)
  albumartist: string;
  albumartistsort: string; (* TODO : int ? *)
  artist: string;
  artistsort: string; (* TODO : int ? *)
  comment: string;
  composer: string;
  date: string;
  disc: string; (* TODO : num_on_num *)
  duration: float;
  file: string;
  genre: string;
  id: int;
  last_modified: string;
  name: string;
  performer: string;
  pos: int;
  rate: int;
  time: int;
  title: string;
  track: string; (* TODO : num_on_num *)
}

let empty = {
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
  last_modified =  "";
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
    | p :: remain -> let { key = k; value = v} = Mpd_utils.read_key_val p in
    match k with
      | "album" -> _parse remain { s with album = v }
      | "albumsort" -> _parse remain { s with albumsort = v }
      | "albumartist" -> _parse remain { s with albumartist = v }
      | "albumartistsort" -> _parse remain { s with albumartistsort = v }
      | "artist" -> _parse remain { s with artist = v }
      | "artistsort" -> _parse remain { s with artistsort = v }
      | "comment" -> _parse remain { s with comment = v }
      | "composer" -> _parse remain { s with composer = v }
      | "date" -> _parse remain { s with date = v }
      | "disc" -> _parse remain { s with disc = v }
      | "duration" -> _parse remain { s with duration = float_of_string v }
      | "genre" -> _parse remain { s with album = v }
      | "file" -> _parse remain { s with file = v }
      | "id" -> _parse remain { s with id = int_of_string v }
      | "Last-Modified" -> _parse remain { s with last_modified = v }
      | "name" -> _parse remain { s with title = v }
      | "performer" -> _parse remain { s with performer = v }
      | "pos" -> _parse remain { s with pos = int_of_string v }
      | "rate" -> _parse remain { s with rate = int_of_string v }
      | "time" -> _parse remain { s with time = int_of_string v }
      | "title" -> _parse remain { s with title = v }
      | "track" -> _parse remain { s with track = v }
      | _ -> _parse remain s
    in _parse lines empty

let album {album = a; _} =
  a

let albumsort {albumsort = a; _} =
  a

let albumartist {albumartist = a; _} =
  a

let albumartistsort {albumartist = a; _} =
  a

let artist {artist = a; _} =
  a

let artistsort {artist = a; _} =
  a

let comment {comment = c; _} =
  c

let composer {composer = c; _} =
  c

let date {date = d; _} =
  d

let disc {disc = d; _} =
  d

let duration {duration = d; _} =
  d

let file {file = f; _} =
  f

let genre {genre = g; _} =
  g

let id {id = i; _} =
  i

let last_modified {last_modified = l; _} =
  l

let name {name = n; _} =
  n

let performer {performer = p; _} =
  p

let pos {pos = p; _} =
  p

let rate {rate = r; _} =
  r

let time {time = t; _} =
  t

let title {title = t; _} =
  t

let track {track = t; _} =
  t

