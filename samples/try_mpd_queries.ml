open Sys
open Unix
open Mpd

(* compile with
 * ocamlfind ocamlc -o try_mpd_queries -package str,unix -linkpkg -g mpd_responses.ml mpd.ml try_mpd_queries.ml
 *)
let host = "127.0.0.1"
let port = 6600

let () =
(*  let server_addr = Mpd.get_server_address host in
    let sock = socket PF_INET SOCK_STREAM 0 in
      connect sock (ADDR_INET(server_addr, port));
      print_endline ("received: " ^ (Mpd.read sock));
      Mpd.write sock (Sys.argv.(1) ^"\n");
      print_endline ("received: " ^ (Mpd.read sock));
      close sock;
      *)
      let client = MpdClient.initialize host port in
      print_endline ("received: " ^ (MpdClient.read client));
      MpdClient.write client (Sys.argv.(1) ^"\n");
      print_endline ("received: " ^ (MpdClient.read client));
      MpdClient.close client;
