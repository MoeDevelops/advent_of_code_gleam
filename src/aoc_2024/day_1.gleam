import gleam/int
import gleam/list
import gleam/pair
import gleam/string

type Parsed =
  #(List(Int), List(Int))

pub fn parse(input: String) -> Parsed {
  let complete_list =
    input
    |> string.trim()
    |> string.split("\n")
    |> list.map(fn(line) {
      let assert Ok(#(left_str, right_str)) = string.split_once(line, "   ")
      let assert Ok(left) = int.parse(left_str)
      let assert Ok(right) = int.parse(right_str)
      #(left, right)
    })

  let left =
    complete_list
    |> list.map(pair.first)
    |> list.sort(int.compare)

  let right =
    complete_list
    |> list.map(pair.second)
    |> list.sort(int.compare)

  #(left, right)
}

pub fn pt_1(input: Parsed) -> Int {
  let #(left, right) = input

  list.map2(left, right, fn(left_int, right_int) {
    int.absolute_value(left_int - right_int)
  })
  |> int.sum()
}

pub fn pt_2(input: Parsed) {
  let #(left, right) = input

  list.fold(left, 0, fn(result, left_int) {
    result
    + left_int
    * list.count(right, fn(right_int) { left_int == right_int })
  })
}
