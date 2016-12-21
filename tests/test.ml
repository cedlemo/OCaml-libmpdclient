(* ocamlfind ocamlc -o test -package oUnit,str -linkpkg -g mpd_responses.ml mpd.ml test.ml *)
(* ocamlfind ocamlc -o test -package oUnit,str,libmpdclient -linkpkg -g test.ml *)

open OUnit2
open Mpd
open Protocol

let test_ok test_ctxt =  assert_equal true (let response = Protocol.parse_response "OK\n" in
match response with
| Ok -> true
| Error _ -> false
)

let test_error_50 test_ctxt =  assert_equal true (let response = Protocol.parse_response "ACK [50@1] {play} error while playing\n" in
match response with
| Ok -> false
| Error (er_val, cmd_num, cmd, message) -> er_val = No_exist && cmd_num = 1 && cmd = "play" &&
message = "error while playing"
)

let test_error_1 test_ctxt =  assert_equal true (let response = Protocol.parse_response "ACK [1@12] {play} error while playing\n" in
match response with
| Ok -> false
| Error (er_val, cmd_num, cmd, message) -> er_val = Not_list && cmd_num = 12 && cmd = "play" &&
message = "error while playing"
)

let mpd_responses_parsing_tests =
  "Mpd responses parsing tests" >:::
    ["test OK" >:: test_ok;
     "test error 50" >:: test_error_50;
     "test error 1" >:: test_error_1]

let () =
  run_test_tt_main mpd_responses_parsing_tests
