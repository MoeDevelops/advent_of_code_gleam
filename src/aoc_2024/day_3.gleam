import gleam/int
import gleam/list
import gleam/result
import gleam/string

type Parsed =
  String

pub fn parse(input: String) -> Parsed {
  input
  |> string.replace("\n", "")
  |> string.trim()
}

fn pop_start(str: String) -> String {
  let assert Ok(new) = string.pop_grapheme(str)
  new.1
}

fn traverse_mul(str: String, results: List(#(Int, Int))) {
  let result = case str {
    "mul(" <> rest -> {
      use #(num1_str, rest) <- result.try(string.split_once(rest, ","))
      use #(num2_str, _) <- result.try(string.split_once(rest, ")"))
      use num1 <- result.try(int.parse(num1_str))
      use num2 <- result.try(int.parse(num2_str))
      Ok(#(num1, num2))
    }
    _ -> Error(Nil)
  }

  case result, string.is_empty(str) {
    Ok(values), True -> [values, ..results]
    _, True -> results
    Ok(values), _ ->
      traverse_mul(pop_start(str), list.append(results, [values]))
    _, _ -> traverse_mul(pop_start(str), results)
  }
}

pub fn pt_1(input: Parsed) -> Int {
  input
  |> traverse_mul([])
  |> list.map(fn(pair) {
    let #(num1, num2) = pair
    num1 * num2
  })
  |> int.sum()
}

type TraveseResult {
  Do
  Dont
  Mul(Int, Int)
  Neither
}

fn traverse_mul_do_dont(str: String, results: List(#(Int, Int)), do: Bool) {
  let result = case str, do {
    "mul(" <> rest, True ->
      case
        {
          use #(num1_str, rest) <- result.try(string.split_once(rest, ","))
          use #(num2_str, _) <- result.try(string.split_once(rest, ")"))
          use num1 <- result.try(int.parse(num1_str))
          use num2 <- result.try(int.parse(num2_str))
          Ok(Mul(num1, num2))
        }
      {
        Ok(mul) -> mul
        _ -> Neither
      }
    "do()" <> _, _ -> Do
    "don't()" <> _, _ -> Dont
    _, _ -> Neither
  }

  case result, string.is_empty(str) {
    Mul(num1, num2), True -> [#(num1, num2), ..results]
    _, True -> results
    Mul(num1, num2), _ ->
      traverse_mul_do_dont(pop_start(str), [#(num1, num2), ..results], do)
    Do, _ -> traverse_mul_do_dont(pop_start(str), results, True)
    Dont, _ -> traverse_mul_do_dont(pop_start(str), results, False)
    _, _ -> traverse_mul_do_dont(pop_start(str), results, do)
  }
}

pub fn pt_2(input: Parsed) {
  input
  |> traverse_mul_do_dont([], True)
  |> list.map(fn(pair) {
    let #(num1, num2) = pair
    num1 * num2
  })
  |> int.sum()
}
