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

(** Music_database module: regroups data base related commands. *)

val find:
  Client.t -> (Tags.search_tags * string) list -> ?sort:Tags.t -> ?window:(int * int)
  -> unit -> (Song.t list, Protocol.ack_error * int * string * string) result
(** Find songs in the db that match exactly the a list of pairs (tag, exact_pattern). The
    exact_pattern is a string and the tah can be any tag supported by MPD, or
    one of the special parameters:
    - any            checks all tag values
    - file           checks the full path (relative to the music directory)
    - base           restricts the search to songs in the given directory (also relative to the music directory)
    - modified-since compares the file's time stamp with the given value (ISO 8601 or UNIX time stamp) *)

val findadd:
  Client.t -> (Tags.search_tags * string) list -> Protocol.response
(** Find songs in the db that and adds them to current playlist. Parameters
    have the same meaning as for find. *)

val search:
  Client.t -> (Tags.search_tags * string) list -> ?sort:Tags.t -> ?window:(int * int)
  -> unit -> (Song.t list, Protocol.ack_error * int * string * string) result
(** Search for any song that contains WHAT. Parameters have the same meaning
    as for find, except that search is not case sensitive. *)

val searchadd:
  Client.t -> (Tags.search_tags * string) list -> Protocol.response
(** Search for any song that contains WHAT in tag TYPE and adds them to
    current playlist.
    Parameters have the same meaning as for findadd, except that search is not
    case sensitive. *)

val searchaddpl:
  Client.t -> string -> (Tags.search_tags * string) list -> Protocol.response
(** Search for any song that contains WHAT in tag TYPE and adds them to the
   playlist named NAME.  If a playlist by that name doesn't exist it is
   created. Parameters have the same meaning as for find, except that search is
   not case sensitive. *)

(** basic type for the response of the count command. *)
type song_count = { songs: int; playtime: float; misc: string }

val count:
  Client.t -> (Tags.t * string) list -> ?group:Tags.t -> unit
  -> (song_count list, string) result
(** Get a count of songs with filters. For examples: count group artist will
   return for each artist the number of sons, the total playtime and the
   name of the artist in misc.
   Counts the number of songs and their total playtime in the db matching TAG
   exactly. The group keyword may be used to group the results by a tag. The
   following prints per-artist counts:
   count group artist
   count genre metal date 2016 group artist
 *)

val list:
  Client.t -> Tags.t -> (Tags.t * string) list -> (string list, string) result
(** Get a list based on some filer. For example "list album artist "Elvis Presley""
    will return a list of the album names of Elvis Presley that exists in the
    music database. *)

val update:
  Client.t -> string option -> Protocol.response
(** Updates the music database: find new files, remove deleted files, update
    modified files. URI is a particular directory or song/file to update. If
    you do not specify it, everything is updated.
    Prints "updating_db: JOBID" where JOBID is a positive number identifying
    the update job. You can read the current job id in the status response. *)

val rescan:
  Client.t -> string option -> Protocol.response
(** Same as update, but also rescans unmodified files. *)

(**/**)
(*
listfiles [URI]
Lists the contents of the directory URI, including files are not recognized by MPD. URI can be a path relative to the music directory or an URI understood by one of the storage plugins. The response contains at least one line for each directory entry with the prefix "file: " or "directory: ", and may be followed by file attributes such as "Last-Modified" and "size".
For example, "smb://SERVER" returns a list of all shares on the given SMB/CIFS server; "nfs://servername/path" obtains a directory listing from the NFS server.

lsinfo [URI]
Lists the contents of the directory URI.
When listing the root directory, this currently returns the list of stored playlists. This behavior is deprecated; use "listplaylists" instead.
This command may be used to list metadata of remote files (e.g. URI beginning with "http://" or "smb://").
Clients that are connected via UNIX domain socket may use this command to read the tags of an arbitrary local file (URI is an absolute path).

readcomments [URI]
Read "comments" (i.e. key-value pairs) from the file specified by "URI". This "URI" can be a path relative to the music directory or an absolute path.
This command may be used to list metadata of remote files (e.g. URI beginning with "http://" or "smb://").
The response consists of lines in the form "KEY: VALUE". Comments with suspicious characters (e.g. newlines) are ignored silently.
The meaning of these depends on the codec, and not all decoder plugins support it. For example, on Ogg files, this lists the Vorbis comments.
Searches for any song that contains WHAT in tag TYPE and adds them to current playlist.
Parameters have the same meaning as for find, except that search is not case sensitive.
*)
(**/**)
