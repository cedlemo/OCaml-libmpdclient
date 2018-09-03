open OUnit
open Lwt.Infix

open Test_configuration

let printer = fun s -> s

let init_client () =
  let connection = Mpd.Connection.initialize host port in
  let client = Mpd.Client.initialize connection in
  let () = match Mpd.Music_database.update client None with
    | Error (_, _, _, message) ->
      let information = "Error when updating database " in
      assert_equal ~printer information message
    | Ok _ -> ()
  in
  client

let init_client_lwt () =
  Mpd.Connection_lwt.initialize host port
  >>= fun connection ->
  Mpd.Client_lwt.initialize connection

let queue_length client =
  match Mpd.Queue.playlist client with
  | Mpd.Queue.PlaylistError _ -> -1
  | Mpd.Queue.Playlist p -> List.length p

let queue_length_lwt client =
  Mpd.Queue_lwt.playlist client
  >>= function
  | Mpd.Queue_lwt.PlaylistError _ -> Lwt.return (-1)
  | Mpd.Queue_lwt.Playlist p -> Lwt.return (List.length p)

let ensure_playlist_is_loaded client =
  if queue_length client <= 0 then begin
    match Mpd.Stored_playlists.load client "bach" () with
    | Error (_, _, _, message) ->
      let information = "Error when loading playlist" in
      assert_equal ~printer information message
    | Ok _ -> ()
  end

let ensure_playback_is_stopped client =
  ignore(Mpd.Playback.stop client)

let ensure_playlist_is_cleared client =
  ignore(Mpd.Queue.clear client)

let run_test f =
  let client = init_client () in
  let () = f client in
  Mpd.Client.close client

let run_test_lwt f =
  ignore(Lwt_main.run begin
      init_client_lwt ()
      >>= fun client ->
      f client
      >>= fun _ ->
      Mpd.Client_lwt.close client
    end)

let run_test_on_playlist f =
  run_test begin fun client ->
    let () = f client in
    ensure_playlist_is_cleared client
  end

let run_test_on_playlist_lwt f =
  run_test_lwt begin fun client ->
    f client
    >>= fun _ ->
    Mpd.Queue_lwt.clear client
  end

let assert_state client s test_name =
  match Mpd.Client.status client with
  | Error message ->
    assert_equal ~printer:(fun s -> test_name ^ s)
      "Unable to get status" message
  | Ok status ->
    assert_equal ~printer:(fun s ->
        test_name ^ (Mpd.Status.string_of_state s)
      ) s (Mpd.Status.state status)

let assert_state_w_delay _client s test_name =
  let () = Unix.sleep 2 in
  assert_state s test_name

let check_state client s =
  match Mpd.Client.status client with
  | Error _message ->
    false
  | Ok status ->
    s == Mpd.Status.state status

let bad_branch error =
  assert_equal ~printer "This should not have been reached " error

let artist = "Bach JS"

let bad_name_artist = "bACH js"

let album = "Die Kunst der Fuge, BWV 1080, for Piano"

(* List of songs returned by Music_database.list *)
let songs =[
  "Contrapunctus 1";
  "Contrapunctus 10 a 4 alla Decima";
  "Contrapunctus 11 a 4";
  "Contrapunctus 2";
  "Contrapunctus 3";
  "Contrapunctus 4";
  "Contrapunctus 5";
  "Contrapunctus 6 a 4 in Stylo Francese";
  "Contrapunctus 7 a 4 per Augmentationem et Diminutionem";
  "Contrapunctus 8 a 3";
  "Contrapunctus 9 a 4 alla Duodecima";
]

(* List of songs when the Basch playlist is loaded. *)
let queue =[
  "Contrapunctus 1";
  "Contrapunctus 2";
  "Contrapunctus 3";
  "Contrapunctus 4";
  "Contrapunctus 5";
  "Contrapunctus 6 a 4 in Stylo Francese";
  "Contrapunctus 7 a 4 per Augmentationem et Diminutionem";
  "Contrapunctus 8 a 3";
  "Contrapunctus 9 a 4 alla Duodecima";
  "Contrapunctus 10 a 4 alla Decima";
  "Contrapunctus 11 a 4";
]

let rec compare l1 l2 = match l1, l2 with
  | [], [] -> true
  | [], _ -> false
  | _, [] -> false
  | h1 :: t1, h2 :: t2 -> h1 = h2 && compare t1 t2
