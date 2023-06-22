type t =
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

type search_tags = Any | File | Base | Modified_since | Mpd_tag of t

let search_tag_to_string = function
  | Any -> "any"
  | File -> "file"
  | Base -> "base"
  | Modified_since -> "modified-since"
  | Mpd_tag t -> tag_to_string t

let build_tag_parameter printer tags =
  let tag_and_param_to_string (t, p) =
    Printf.sprintf "%s \"%s\"" (printer t) p
  in
  List.map tag_and_param_to_string tags |> String.concat " "
