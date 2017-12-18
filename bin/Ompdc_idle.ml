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
open Lwt.Infix
open Notty
open Notty_lwt
open Ompdc_common

module Terminal = Notty_lwt.Term

let gen_state_img status =
  let state = Mpd.Status.state status in
    let state_img = match state with
      | Mpd.Status.Play -> I.(string A.(fg green) "play")
      | Mpd.Status.Pause -> I.(string A.(fg lightblack) "Pause")
      | Mpd.Status.Stop -> I.(string A.(fg black ++ bg lightblack) "Stop")
      | Mpd.Status.ErrState -> I.(string A.(fg red) "State Error")
  in
  I.(string A.(fg white) "[state ] : " <|> state_img)

let gen_volume_img status =
  let volume = Mpd.Status.volume status in
  I.(strf ~attr:A.(fg white)   "[volume] : %d" volume)

let gen_playlist_img status client (w, h) =
  let current_song = Mpd.Status.song status in
  Mpd.Queue_lwt.playlist client
  >>= function
    | PlaylistError message -> Lwt.return I.(strf ~attr:A.(fg red) "Error: %s" message)
    | Playlist songs ->
      let gen_song_img i song =
        let title = Mpd.Song.title song in
        let artist = Mpd.Song.artist song in
        if current_song = i then
          I.(strf ~attr:A.(fg lightred ++ bg lightblack) "+ %s : %s" title artist)
        else
          I.(strf ~attr:A.(fg lightblack) "- %s : %s" title artist)
      in
      let song_imgs = List.mapi gen_song_img songs in
      let lines = List.map (fun i ->
      let left_margin = 4 in
      let i_w = I.width i in
      let remain = let r = w - (i_w + left_margin) in (max r 0) in
      I.hpad left_margin remain i) song_imgs in
      Lwt.return I.(vcat lines)

let render (w, h) client =
  Mpd.Client_lwt.status client
  >>= fun response ->
    match response with
    | Error message -> Lwt.return I.(strf ~attr:A.(fg red) "[there is a pb %s]" message)
    | Ok status -> let state_img = gen_state_img status in
      let volume_img = gen_volume_img status in
      gen_playlist_img status client (w, h)
      >>= fun songs_img ->
      Lwt.return I.(state_img <-> volume_img <-> songs_img)

let listen_mpd_event client =
  Mpd.Client_lwt.idle client >|= fun evt -> `Mpd_event evt

let event term = Lwt_stream.get (Terminal.events term) >|= function
  | Some (`Resize _ | #Unescape.event as x) -> x
  | None -> `End

let rec loop term (e, t) dim client timestamp =
  (e <?> t) >>= function
  | `End | `Key (`Escape, []) | `Key (`ASCII 'C', [`Ctrl]) ->
      Lwt.return_unit
  | `Mpd_event event_name ->
      render dim client
      >>= fun img ->
        Terminal.image term img
        >>= fun () ->
            let now = Unix.time () in
            loop term (e, listen_mpd_event client) dim client now
  | `Resize dim ->
      let now = Unix.time () in
      if (timestamp -. now >= 1.0) then
        render dim client
        >>= fun img ->
          Terminal.image term img
          >>= fun () ->
          loop term (event term, t) dim client now
      else loop term (event term, t) dim client timestamp
  | _ ->
      let now = Unix.time () in
      if (timestamp -. now >= 1.0) then
      render dim client
      >>= fun img ->
        Terminal.image term img
        >>= fun () ->
        loop term (event term, t) dim client now
      else loop term (event term, t) dim client timestamp


let interface client =
  let term = Terminal.create () in
  let size = Terminal.size term in
  render size client
  >>= fun img ->
    Terminal.image term img
    >>= fun () ->
    let timestamp = Unix.time () in
    loop term (event term, listen_mpd_event client) size client timestamp

let idle common_opts =
  let open Mpd in
  let {host; port} = common_opts in
  let main_thread =
    Mpd.Connection_lwt.initialize host port
    >>= fun connection ->
      Mpd.Client_lwt.initialize connection
      >>= fun client ->
        interface client
  in
  Lwt_main.run (
    Lwt.catch
      (fun () -> main_thread)
      (function
        | Mpd.Connection_lwt.Lwt_unix_exn message ->
            Lwt_io.write_line Lwt_io.stderr message
        | _ -> Lwt_io.write_line Lwt_io.stderr "Exception not handled. Exit ..."
      )
  )

open Cmdliner
let cmd =
  let doc = "Use Ompdc an Mpd server events listener. Quit with Ctl+Alt+C." in
  let man = [ `S Manpage.s_description;
              `P "Idle command that display events of the Mpd server.";
              `Blocks help_section
  ] in
  Term.(const idle $ common_opts_t),
  Term.info "idle" ~doc ~sdocs ~exits ~man
