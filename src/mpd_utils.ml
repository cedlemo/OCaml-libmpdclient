(*
 * Copyright 2017 Cedric LE MOIGNE, cedlemo@gmx.com
 * This file is part of OCaml-libmpdclient.
 *
 * Topinambour is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * any later version.
 *
 * Topinambour is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with OCaml-libmpdclient.  If not, see <http://www.gnu.org/licenses/>.
 *)

(** Split multiline string into a list of strings *)
let split_lines strings =
  Str.split (Str.regexp "\n") strings

(** Type that can save the id of an element which can be an int or two int *)
type item_id = Simple of int | Num_on_num of int * int

(** Split string like "8/14" to 8 and 14, returns (-1, -1) if it fails.
 * is used in track and disc tab of the song data *)
let num_on_num_parse numbers =
  let is_simple_number = Str.string_match (Str.regexp "^[0-9]+$") numbers 0 in
  let is_num_on_num = Str.string_match (Str.regexp "\\([0-9]+\\)/\\([0-9]+\\)") numbers 0 in
  if is_simple_number then Simple (int_of_string numbers)
  else if is_num_on_num then
    Num_on_num (int_of_string (Str.matched_group 1 numbers),
                int_of_string (Str.matched_group 2 numbers))
  else
    Num_on_num (-1, -1)

(** Create a type used when splitting a line which has the form key: value .
 * This type is used by Mpd.Utils.read_key_val. *)
type pair = { key : string; value : string }

(** Split a line with the form "k: v" in the value of type pair *)
let read_key_val str =
  let pattern = Str.regexp "\\(.*\\): \\(.*\\)" in
  if Str.string_match pattern str 0 then let k = Str.matched_group 1 str in
  let v = Str.matched_group 2 str in {key = k; value = v}
  else {key = ""; value = ""}

(** Returns all the values of a list of strings that have the key/value form. *)
let values_of_pairs list_of_pairs =
  let rec _values pairs acc =
    match pairs with
    | [] -> acc
    | pair :: remainder -> let {key = _; value = v} = read_key_val pair in _values remainder (v :: acc)
  in _values list_of_pairs []

(** Get a boolean value from a string number. The string "0" is false while all
 * other string is true. *)
let bool_of_int_str b =
  match b with
  | "0" -> false
  | _   -> true


