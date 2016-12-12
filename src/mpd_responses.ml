(* https://github.com/sol/mpd/blob/master/src/ack.h *)
type ack_error =
  | Not_list        (* 1 *)
  | Arg             (* 2 *)
  | Password        (* 3 *)
  | Permission      (* 4 *)
	| Unknown         (* 5 *)
  | No_exist        (* 50 *)
	| Playlist_max    (* 51 *)
	| System          (* 52 *)
	| Playlist_load   (* 53 *)
	| Update_already  (* 54 *)
	| Player_sync     (* 55 *)
  | Exist           (* 56 *)

type response = Ok | Error of (ack_error * int * string * string)

let error_name = function
  | Not_list      -> "Not_list"
  | Arg           -> "Arg"
  | Password      -> "Password"
  | Permission    -> "Permission"
	| Unknown       -> "Unknown"
  | No_exist      -> "No_exist"
	| Playlist_max  -> "Playlist_max"
	| System        -> "System"
	| Playlist_load -> "Playlist_load"
	| Update_already-> "Update_already"
	| Player_sync   -> "Player_sync"
  | Exist         -> "Exist"

