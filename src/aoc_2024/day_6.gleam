import gleam/bool
import gleam/list
import gleam/pair
import gleam/string

type Parsed =
  List(List(String))

pub fn parse(input: String) -> Parsed {
  input
  |> string.trim
  |> string.split("\n")
  |> list.map(string.to_graphemes)
}

fn get_index(list: List(a), search: a, index: Int) -> Result(Int, Nil) {
  case list {
    [item, ..] if item == search -> Ok(index)
    [_, ..rest] -> get_index(rest, search, index + 1)
    [] -> Error(Nil)
  }
}

fn at_index(list: List(a), index: Int, current_index: Int) -> Result(a, Nil) {
  case list {
    [item, ..] if index == current_index -> Ok(item)
    [_, ..rest] -> at_index(rest, index, current_index + 1)
    [] -> Error(Nil)
  }
}

fn set_index(
  list: List(a),
  index: Int,
  current_index: Int,
  before: List(a),
  item: a,
) -> Result(List(a), Nil) {
  case list {
    [] -> Error(Nil)
    [_, ..rest] if index == current_index ->
      Ok(list.append(before, [item, ..rest]))
    [current, ..rest] ->
      set_index(
        rest,
        index,
        current_index + 1,
        list.append(before, [current]),
        item,
      )
  }
}

fn turn_right(matrix: List(List(a))) -> List(List(a)) {
  case
    matrix
    |> list.map(list.split(_, 1))
  {
    [#([], []), ..] -> []
    pairs -> [
      list.map(pairs, pair.first) |> list.flatten,
      ..turn_right(list.map(pairs, pair.second))
    ]
  }
}

fn walk(
  full_matrix: List(List(String)),
  matrix: List(List(String)),
  index: Int,
) -> List(List(String)) {
  let result = case matrix {
    [first, second, ..] -> {
      use <- bool.guard(!list.contains(second, "^"), Error(Nil))
      let assert Ok(guard_index) = get_index(second, "^", 0)
      let assert Ok(above) = at_index(first, guard_index, 0)

      case above {
        "#" -> {
          let turned =
            full_matrix
            |> turn_right
            |> list.reverse
          Ok(walk(turned, turned, 0))
        }
        _ -> {
          let assert Ok(new_first) = set_index(first, guard_index, 0, [], "^")
          let assert Ok(new_second) = set_index(second, guard_index, 0, [], "X")
          let assert Ok(new_full_matrix) =
            set_index(full_matrix, index, 0, [], new_first)
          let assert Ok(new_full_matrix) =
            set_index(new_full_matrix, index + 1, 0, [], new_second)
          Ok(walk(new_full_matrix, new_full_matrix, 0))
        }
      }
    }
    [_] -> Ok(full_matrix)
    _ -> Error(Nil)
  }

  case result {
    Ok(finished) -> finished
    _ -> walk(full_matrix, list.drop(matrix, 1), index + 1)
  }
}

pub fn pt_1(input: Parsed) -> Int {
  walk(input, input, 0)
  |> list.flatten
  |> string.concat
  |> string.to_graphemes
  |> list.count(fn(char) { char == "^" || char == "X" })
}

pub fn pt_2(input: Parsed) -> Int {
  todo
}
