open Lwt.Infix

(* compile with
 * ocamlfind ocamlc -o mpd_playlist_info -package str,unix -linkpkg -g mpd_responses.ml mpd.ml mpd_playlist_info.ml
 * or
 * ocamlfind ocamlc -o mpd_playlist_info -package str,unix,libmpdclient -linkpkg -g mpd_playlist_info.ml
 *)
let host = "127.0.0.1"
let port = 6600

let lwt_print_line str =
  Lwt_io.write_line Lwt_io.stdout str

let main_thread =
   Mpd.LwtConnection.initialize host port
   >>= fun connection ->
    match connection with
    | None -> Lwt.return ()
    | Some (c) ->Mpd.LwtClient.initialize c
                 >>= fun client ->
                   MpdLwtQueue.playlist client
                   >>= function
                   | MpdLwtQueue.PlaylistError message -> lwt_print_line ("err" ^ message)
                   | MpdLwtQueue.Playlist playlist ->
                     Lwt.return playlist
                     >>= fun p ->
                       let n = List.length p in
                       lwt_print_line ("Number of songs : " ^ (string_of_int n))
                       >>= fun () ->
                         Lwt_list.iter_s (fun song ->
                           let id = string_of_int (Song.id song) in
                           let title = Song.title song in
                           let album = Song.album song in
                           lwt_print_line (String.concat " " ["\t*"; id; title; album])
                         ) p
                         >>= fun () ->
                           Mpd.LwtClient.close client

let () =
  Lwt_main.run main_thread
