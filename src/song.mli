type s
val empty: s
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
