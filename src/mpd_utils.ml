(** Split multiline string into a list of strings *)
let split_lines strings =
  Str.split (Str.regexp "\n") strings

(** Create a type used when splitting a line which has the form key: value .
 * This type is used by Mpd.Utils.read_key_val. *)
type pair = { key : string; value : string }

(** Split a line with the form "k: v" in the value of type pair :
  * { key = k; value = v } *)
let read_key_val str =
  let pattern = Str.regexp ": " in
  let two_str_list = Str.bounded_split pattern str 2 in
  let v =  List.hd (List.rev two_str_list) in
  {key = List.hd two_str_list; value = v}

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


