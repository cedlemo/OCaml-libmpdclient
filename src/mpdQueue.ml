open Mpd_utils

type p =
  | PlaylistError of string | Playlist of Song.s list

(** Adds the file URI to the playlist (directories add recursively). URI can also be a single file. *)
let add client uri =
  Mpd.Client.send_command client uri

let addid client uri position =
  let cmd = String.concat " " ["addid"; uri; string_of_int position] in
  let response = Mpd.Client.send_command client cmd in
  match response with
  |Protocol.Ok (song_id) -> let lines = Mpd_utils.split_lines song_id in
  let rec parse lines =
    match lines with
      | [] -> -1
      | line :: remain -> let { key = k; value = v} = Mpd_utils.read_key_val line in
      if (k = "Id") then int_of_string v
                          else parse remain
      in parse lines
      |Protocol.Error (_) -> -1

(** Clears the current playlist. *)
let clear client =
  Mpd.Client.send_command client "clear"

(** Deletes a song or a set of songs from the playlist. The song or the range
 * of songs are identified by the position in the playlist. *)
let delete client position ?position_end () =
  let cmd = match position_end with
  |None -> String.concat " " ["delete"; string_of_int position]
  |Some pos_end -> String.concat "" ["delete ";
                                     string_of_int position;
                                     ":";
                                     string_of_int pos_end]
in Mpd.Client.send_command client cmd

(** Deletes the song SONGID from the playlist. *)
let deleteid client id =
  Mpd.Client.send_command client (String.concat " " ["deleteid"; string_of_int id])

(** Moves the song at FROM or range of songs at START:END to TO in
 * the playlist. *)
let move client position_from ?position_end position_to () =
  let cmd = match position_end with
  |None -> String.concat " " ["move";
                              string_of_int position_from;
                              string_of_int position_to]
  |Some pos_end -> String.concat "" ["move ";
                                     string_of_int position_from;
                                     ":";
                                     string_of_int pos_end;
                                     " ";
                                     string_of_int position_to]
in Mpd.Client.send_command client cmd

(** Moves the song with FROM (songid) to TO (playlist index) in the playlist.
 * If TO is negative, it is relative to the current song in the playlist
 * (if there is one). *)
let moveid client id position_to =
  Mpd.Client.send_command client (String.concat " " ["moveid";
                                            string_of_int id;
                                            string_of_int position_to])

let get_song_id song =
  let pattern = "\\([0-9]+\\):file:.*" in
  let found = Str.string_match (Str.regexp pattern) song 0 in
  if found then Str.matched_group 1 song
  else "none"

let rec _build_songs_list client songs l =
  match songs with
  | [] -> Playlist (List.rev l)
  | h :: q -> let song_infos_request = "playlistinfo " ^ (get_song_id h) in
  match Mpd.Client.send_request client song_infos_request with
  | Protocol.Error (ack_val, ack_cmd_num, ack_cmd, ack_message)-> PlaylistError (ack_message)
  | Protocol.Ok (song_infos) -> let song = Song.parse (Mpd_utils.split_lines song_infos) in
   _build_songs_list client q (song :: l)

let playlist client =
  match Mpd.Client.send_request client "playlist" with
  | Protocol.Error (ack_val, ack_cmd_num, ack_cmd, ack_message)-> PlaylistError (ack_message)
  | Protocol.Ok (response) -> let songs = Mpd_utils.split_lines response in
  _build_songs_list client songs []
