import gleam/int
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

pub fn pt_2(input: Parsed) -> Int {
  use numbers <- list.count(input)
  use numbers <- list.any([
    numbers,
    ..list.combinations(numbers, list.length(numbers) - 1)
  ])

  let assert Ok(differences) = map_difference(numbers)

  list.all(differences, fn(num) { num <= 3 && num >= 1 })
  || list.all(differences, fn(num) { num >= -3 && num <= -1 })
}
