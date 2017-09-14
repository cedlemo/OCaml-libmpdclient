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

open Sys
open Unix

open Protocol
open Status
open Utils

type c =
  { hostname : string; port : int; ip : Unix.inet_addr; socket : Unix.file_descr }

let unix_error_message (error, fn_name, param_name) user_str =
  let strs = [Unix.error_message error; fn_name; param_name; user_str; ".Exiting..."] in
  let message = String.concat " " strs in
  let _ = prerr_endline message in
  exit 2

let initialize hostname port =
  let ip = try (Unix.gethostbyname hostname).h_addr_list.(0)
  with Not_found ->
    let _ = prerr_endline (hostname ^ ": Host not found") in
    exit 2
  in
  let socket = try Unix.socket PF_INET SOCK_STREAM 0
  with Unix_error (error, fn_name, param_name) ->
    let custom_message = ": unable to create socket" in
    unix_error_message (error, fn_name, param_name) custom_message
  in
  let _ = try Unix.connect socket (ADDR_INET(ip, port))
  with Unix_error (error, fn_name, param_name) ->
    let custom_message = Printf.sprintf ": unable to connect to %s:%d" hostname port in
    unix_error_message (error, fn_name, param_name) custom_message
  in
  { hostname = hostname; port = port; ip = ip; socket = socket}

let close { socket; _} =
  try (let _ = Unix.set_nonblock socket in Unix.close socket)
  with Unix_error (error, fn_name, param_name) ->
    let custom_message = ": unable to close socket" in
    unix_error_message (error, fn_name, param_name) custom_message

let socket { socket; _} = socket

let write c str =
  let socket = socket c in
  let len = String.length str in
  ignore(send socket str 0 len [])

let read c =
  let socket = socket c in
  let _ = Unix.set_nonblock socket in
  let str = Bytes.create 128 in
  let rec _read s acc =
    try
      let recvlen = Unix.recv s str 0 128 [] in
      let recvstr = String.sub str 0 recvlen in _read s (recvstr :: acc)
  with
      | Unix_error(Unix.EAGAIN, _, _) -> if acc = [] then _read s acc else acc
      in String.concat "" (List.rev (_read socket []))
