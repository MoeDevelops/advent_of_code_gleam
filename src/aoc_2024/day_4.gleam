import gleam/list
import gleam/option.{None, Some}
import gleam/string

type Parsed =
  List(List(String))

pub fn parse(input: String) -> Parsed {
  input
  |> string.trim()
  |> string.split("\n")
  |> list.map(string.to_graphemes)
}

fn count_diagonal_tl2br(
  row1: List(String),
  row2: List(String),
  row3: List(String),
  row4: List(String),
  count: Int,
) -> Int {
  let next = fn(count) {
    count_diagonal_tl2br(
      list.drop(row1, 1),
      list.drop(row2, 1),
      list.drop(row3, 1),
      list.drop(row4, 1),
      count,
    )
  }

  case row1, row2, row3, row4 {
    [_, _, _], _, _, _ -> count
    ["X", ..], [_, "M", ..], [_, _, "A", ..], [_, _, _, "S", ..] ->
      next(count + 1)
    ["S", ..], [_, "A", ..], [_, _, "M", ..], [_, _, _, "X", ..] ->
      next(count + 1)
    _, _, _, _ -> next(count)
  }
}

fn count_diagonal_tr2bl(
  row1: List(String),
  row2: List(String),
  row3: List(String),
  row4: List(String),
  count: Int,
) -> Int {
  let next = fn(count) {
    count_diagonal_tr2bl(
      list.drop(row1, 1),
      list.drop(row2, 1),
      list.drop(row3, 1),
      list.drop(row4, 1),
      count,
    )
  }

  case row1, row2, row3, row4 {
    [_, _, _], _, _, _ -> count
    [_, _, _, "X", ..], [_, _, "M", ..], [_, "A", ..], ["S", ..] ->
      next(count + 1)
    [_, _, _, "S", ..], [_, _, "A", ..], [_, "M", ..], ["X", ..] ->
      next(count + 1)
    _, _, _, _ -> next(count)
  }
}

fn count_vertical(
  row1: List(String),
  row2: List(String),
  row3: List(String),
  row4: List(String),
  count: Int,
) -> Int {
  let next = fn(count) {
    count_vertical(
      list.drop(row1, 1),
      list.drop(row2, 1),
      list.drop(row3, 1),
      list.drop(row4, 1),
      count,
    )
  }

  case row1, row2, row3, row4 {
    [], _, _, _ -> count
    ["X", ..], ["M", ..], ["A", ..], ["S", ..] -> next(count + 1)
    ["S", ..], ["A", ..], ["M", ..], ["X", ..] -> next(count + 1)
    _, _, _, _ -> next(count)
  }
}

fn count_horizontal(input: List(String), count: Int) -> Int {
  let next = fn(count) { count_horizontal(list.drop(input, 1), count) }

  case input {
    [_, _, _] -> count
    ["X", "M", "A", "S", ..] -> next(count + 1)
    ["S", "A", "M", "X", ..] -> next(count + 1)
    _ -> next(count)
  }
}

pub fn pt_1(input: Parsed) -> Int {
  {
    let init_val = #(0, None, None, None)
    use #(count, row1_, row2_, row3_), row <- list.fold(input, init_val)

    let count = count_horizontal(row, count)

    case row1_, row2_, row3_ {
      None, _, _ -> #(count, Some(row), None, None)
      Some(row1), None, _ -> #(count, Some(row1), Some(row), None)
      Some(row1), Some(row2), None -> #(
        count,
        Some(row1),
        Some(row2),
        Some(row),
      )
      Some(row1), Some(row2), Some(row3) -> {
        let count = count_diagonal_tl2br(row1, row2, row3, row, count)
        let count = count_diagonal_tr2bl(row1, row2, row3, row, count)
        let count = count_vertical(row1, row2, row3, row, count)
        #(count, Some(row2), Some(row3), Some(row))
      }
    }
  }.0
}

fn count_cross_mas(
  row1: List(String),
  row2: List(String),
  row3: List(String),
  count: Int,
) -> Int {
  let next = fn(count) {
    count_cross_mas(
      list.drop(row1, 1),
      list.drop(row2, 1),
      list.drop(row3, 1),
      count,
    )
  }

  case row1, row2, row3 {
    [_, _], _, _ -> count
    ["M", _, "M", ..], [_, "A", _, ..], ["S", _, "S", ..] -> next(count + 1)
    ["M", _, "S", ..], [_, "A", _, ..], ["M", _, "S", ..] -> next(count + 1)
    ["S", _, "M", ..], [_, "A", _, ..], ["S", _, "M", ..] -> next(count + 1)
    ["S", _, "S", ..], [_, "A", _, ..], ["M", _, "M", ..] -> next(count + 1)
    _, _, _ -> next(count)
  }
}

pub fn pt_2(input: Parsed) {
  {
    let init_val = #(0, None, None)
    use #(count, row1_, row2_), row <- list.fold(input, init_val)

    case row1_, row2_ {
      None, _ -> #(count, Some(row), None)
      Some(row1), None -> #(count, Some(row1), Some(row))
      Some(row1), Some(row2) -> {
        let count = count_cross_mas(row1, row2, row, count)
        #(count, Some(row2), Some(row))
      }
    }
  }.0
}
