(** Split multiline string into a list of strings *)
let split_lines strings =
  Str.split (Str.regexp "\n") strings

type pair = { key : string; value : string }

let read_key_val str =
  let pattern = Str.regexp ": " in
  let two_str_list = Str.bounded_split pattern str 2 in
  let v =  List.hd (List.rev two_str_list) in
  {key = List.hd two_str_list; value = v}

let values_of_pairs list_of_pairs =
  let rec _values pairs acc =
    match pairs with
    | [] -> acc
    | pair :: remainder -> let {key = _; value = v} = read_key_val pair in _values remainder (v :: acc)
  in _values list_of_pairs []

let bool_of_int_str b =
  match b with
  | "0" -> false
  | _   -> true


