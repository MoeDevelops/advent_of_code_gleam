import gleam/int
import gleam/io
import gleam/list
import gleam/string

type Parsed =
  List(List(Int))

pub fn parse(input: String) -> Parsed {
  let lines =
    input
    |> string.trim()
    |> string.split("\n")

  use line <- list.map(lines)

  let assert Ok(numbers) =
    line
    |> string.split(" ")
    |> list.try_map(int.parse)

  numbers
}

fn map_difference(numbers: List(Int)) -> Result(List(Int), Nil) {
  case numbers {
    [_] -> Error(Nil)
    [first, second, ..rest] -> Ok(do_map_difference(first, second, rest))
    [] -> Error(Nil)
  }
}

fn do_map_difference(before: Int, current: Int, rest: List(Int)) -> List(Int) {
  let diff = current - before
  case rest {
    [] -> [diff]
    [next, ..rest] -> [diff, ..do_map_difference(current, next, rest)]
  }
}

pub fn pt_1(input: Parsed) -> Int {
  use numbers <- list.count(input)

  let assert Ok(differences) = map_difference(numbers)

  list.all(differences, fn(num) { num <= 3 && num >= 1 })
  || list.all(differences, fn(num) { num >= -3 && num <= -1 })
}

fn lists_without_one(list: List(a)) -> List(List(a)) {
  case list {
    [] -> []
    [_] -> [[]]
    [first, ..rest] -> do_lists_without_one([], first, rest, [])
  }
}

fn do_lists_without_one(
  before: List(a),
  current: a,
  after: List(a),
  lists: List(List(a)),
) -> List(List(a)) {
  case after {
    [next, ..rest] ->
      do_lists_without_one(list.append(before, [current]), next, rest, [
        list.append(before, after),
        ..lists
      ])
    [] -> [before, ..lists]
  }
}

pub fn pt_2(input: Parsed) -> Int {
  use numbers <- list.count(input)

  [numbers, ..lists_without_one(numbers)]
  |> list.any(fn(numbers) {
    let assert Ok(differences) = map_difference(numbers)

    list.all(differences, fn(num) { num <= 3 && num >= 1 })
    || list.all(differences, fn(num) { num >= -3 && num <= -1 })
  })
}
