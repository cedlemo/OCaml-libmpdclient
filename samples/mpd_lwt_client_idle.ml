open Lwt
open Mpd

let host = "127.0.0.1"
let port = 6600

let on_mpd_event event_name =
  match event_name with
  | "player" -> print_endline "Player command has been executed"; Lwt.return false
  | _ -> print_endline (("Not handled -" ^ event_name) ^ "-"); Lwt.return true

let main_thread =
   Mpd.LwtConnection.initialize host port
   >>= fun connection ->
    match connection with
    | None -> Lwt.return ()
    | Some (c) -> Lwt_io.write_line Lwt_io.stdout "Client on"
                  >>= fun () ->
                  Mpd.LwtClient.initialize c
                  >>= fun client ->
                    Lwt_io.write_line Lwt_io.stdout (Mpd.LwtClient.mpd_banner client)
                    >>= fun () ->
                    Mpd.LwtClient.idle client on_mpd_event

let () =
  Lwt_main.run main_thread
