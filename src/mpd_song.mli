type s
val empty: s
val parse: string list -> s
val album: s -> string
val artist: s -> string
val duration: s -> float
val file: s -> string
val genre: s -> string
val id: s -> int
val last_modified: s ->  string
val pos: s -> int
val rate:  s -> int
val time: s -> int
val title: s -> string
val track: s -> int
