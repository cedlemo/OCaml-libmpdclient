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

(** MusicDatabase module: regroups data base related commands. *)

(** type for the Mpd database tags. *)
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

val tag_to_string:
    tags -> string
(*

count {TAG} {NEEDLE} [...] [group] [GROUPTYPE]

Counts the number of songs and their total playtime in the db matching TAG exactly.

The group keyword may be used to group the results by a tag. The following prints per-artist counts:

count group artist

find {TYPE} {WHAT} [...] [sort TYPE] [window START:END]

Finds songs in the db that are exactly WHAT. TYPE can be any tag supported by MPD, or one of the special parameters:

any checks all tag values

file checks the full path (relative to the music directory)

base restricts the search to songs in the given directory (also relative to the music directory)

modified-since compares the file's time stamp with the given value (ISO 8601 or UNIX time stamp)

WHAT is what to find.

sort sorts the result by the specified tag. Without sort, the order is undefined. Only the first tag value will be used, if multiple of the same type exist. To sort by "Artist", "Album" or "AlbumArtist", you should specify "ArtistSort", "AlbumSort" or "AlbumArtistSort" instead. These will automatically fall back to the former if "*Sort" doesn't exist. "AlbumArtist" falls back to just "Artist".

window can be used to query only a portion of the real response. The parameter is two zero-based record numbers; a start number and an end number.

findadd {TYPE} {WHAT} [...]

Finds songs in the db that are exactly WHAT and adds them to current playlist. Parameters have the same meaning as for find.

list {TYPE} [FILTERTYPE] [FILTERWHAT] [...] [group] [GROUPTYPE] [...]

Lists unique tags values of the specified type. TYPE can be any tag supported by MPD or file.

Additional arguments may specify a filter like the one in the find command.

The group keyword may be used (repeatedly) to group the results by one or more tags. The following example lists all album names, grouped by their respective (album) artist:

list album group albumartist

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

search {TYPE} {WHAT} [...] [sort TYPE] [window START:END]

Searches for any song that contains WHAT. Parameters have the same meaning as for find, except that search is not case sensitive.

searchadd {TYPE} {WHAT} [...]

Searches for any song that contains WHAT in tag TYPE and adds them to current playlist.

Parameters have the same meaning as for find, except that search is not case sensitive.

searchaddpl {NAME} {TYPE} {WHAT} [...]

Searches for any song that contains WHAT in tag TYPE and adds them to the playlist named NAME.

If a playlist by that name doesn't exist it is created.

Parameters have the same meaning as for find, except that search is not case sensitive.

update [URI]

Updates the music database: find new files, remove deleted files, update modified files.

URI is a particular directory or song/file to update. If you do not specify it, everything is updated.

Prints "updating_db: JOBID" where JOBID is a positive number identifying the update job. You can read the current job id in the status response.

rescan [URI]

Same as update, but also rescans unmodified files.

 *)
val update:
  Client.t -> string option -> Protocol.response
