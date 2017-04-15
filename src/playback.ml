let next client =
  Mpd.Client.send client "next"

let prev client =
  Mpd.Client.send client "prev"

let stop client =
  Mpd.Client.send client "stop"

let pause client arg =
  match arg with
  | true -> Mpd.Client.send client "pause 1"
  | _    -> Mpd.Client.send client "pause 0"

let play client songpos =
  Mpd.Client.send client (String.concat " " ["play";
                                              string_of_int songpos])

let playid client songid =
  Mpd.Client.send client (String.concat " " ["playid";
                                              string_of_int songid])

let seek client songpos time =
  Mpd.Client.send client (String.concat " " ["seek";
                                              string_of_int songpos;
                                              string_of_float time])

let seekid client songid time =
  Mpd.Client.send client (String.concat " " ["seekid";
                                              string_of_int songid;
                                              string_of_float time])

let seekcur client time =
  Mpd.Client.send client (String.concat " " ["seekcur"; string_of_float time])
