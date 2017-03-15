type s
val empty: s
val parse: string list -> s
val file: s -> string
val last_modified: s ->  string
val artist: s -> string
val title: s -> string
val album: s -> string
val track: s -> int
val rate:  s -> int
val genre: s -> string
val time: s -> int
val duration: s -> float
val pos: s -> int
val id: s -> int
