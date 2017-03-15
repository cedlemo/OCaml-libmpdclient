open Mpd_utils
type s = {
  file: string;
  last_modified:  string;
  artist: string;
  title: string;
  album: string;
  track: int;
  rate: int;
  genre: string;
  time: int;
  duration: float;
  pos: int;
  id: int;
}

let empty = {
  file = "";
  last_modified =  "";
  artist = "";
  title = "";
  album = "";
  track = 0;
  rate = 0;
  genre = "";
  time = 0;
  duration = 0.0;
  pos = 0;
  id = 0;
}

let parse lines =
  let rec _parse pairs s =
    match pairs with
    | [] -> s
    | p :: remain -> let { key = k; value = v} = Mpd_utils.read_key_val p in
    match k with
      | "file" -> _parse remain { s with file = v }
      | "Last-Modified" -> _parse remain { s with last_modified = v }
      | "artist" -> _parse remain { s with artist = v }
      | "title" -> _parse remain { s with title = v }
      | "album" -> _parse remain { s with album = v }
      | "track" -> _parse remain { s with track = int_of_string v }
      | "rate" -> _parse remain { s with rate = int_of_string v }
      | "genre" -> _parse remain { s with album = v }
      | "time" -> _parse remain { s with time = int_of_string v }
      | "duration" -> _parse remain { s with duration = float_of_string v }
      | "pos" -> _parse remain { s with pos = int_of_string v }
      | "id" -> _parse remain { s with id = int_of_string v }
      | _ -> _parse remain s
    in _parse lines empty

let file {file = f; _} =
  f

let last_modified {last_modified = l; _} =
  l

let artist {artist = a; _} =
  a

let title {title = t; _} =
  t

let album {album = a; _} =
  a

let track {track = t; _} =
  t

let rate {rate = r; _} =
  r

let genre {genre = g; _} =
  g

let time {time = t; _} =
  t

let duration {duration = d; _} =
  d

let pos {pos = p; _} =
  p

let id {id = i; _} =
  i
