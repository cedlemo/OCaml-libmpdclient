type s
type state

val empty : s
val parse: string list -> s
val volume: s -> int
val repeat: s -> bool
val random: s -> bool
val single: s -> bool
val consume: s -> bool
val playlist: s -> int
val playlistlength: s -> int
val state: s -> state
val song: s -> int
val songid: s -> int
val nextsong: s -> int
val nextsongid: s -> int
val time: s -> string
val elapsed: s -> float
val duration: s -> float
val bitrate: s -> int
val xfade: s -> int
val mixrampdb: s -> float
val mixrampdelay: s -> int
val audio: s -> string
val updating_db: s -> int
val error: s -> string
