open OUnit
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

let queue_length client =
  match Mpd.Queue.playlist client with
  | Mpd.Queue.PlaylistError _ -> -1
  | Mpd.Queue.Playlist p -> List.length p

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

let run_test_on_playlist f =
  run_test begin fun client ->
    let () = ensure_playlist_is_loaded client in
    let () = ensure_playback_is_stopped client in
    let () = f client in
    let () = ensure_playback_is_stopped client in
    ensure_playlist_is_cleared client
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
