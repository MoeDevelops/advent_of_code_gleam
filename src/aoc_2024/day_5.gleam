import gleam/bool
import gleam/int
import gleam/list
import gleam/order
import gleam/pair
import gleam/result
import gleam/string

type Parsed =
  #(List(#(Int, Int)), List(List(Int)))

pub fn parse(input: String) -> Parsed {
  let assert Ok(#(ordering_rules_block, pages_to_produce_block)) =
    input
    |> string.trim
    |> string.split_once("\n\n")

  let assert Ok(ordering_rules) =
    ordering_rules_block
    |> string.trim
    |> string.split("\n")
    |> list.try_map(string.split_once(_, "|"))
    |> result.then(list.try_map(_, fn(numbers) {
      use num1 <- result.try(int.parse(numbers.0))
      use num2 <- result.try(int.parse(numbers.1))
      Ok(#(num1, num2))
    }))

  let assert Ok(pages_to_produce) =
    pages_to_produce_block
    |> string.trim
    |> string.split("\n")
    |> list.try_map(fn(line) {
      line
      |> string.split(",")
      |> list.try_map(int.parse)
    })

  #(ordering_rules, pages_to_produce)
}

fn get_middle_num(numbers: List(Int)) -> Int {
  let assert Ok(num) =
    list.split(numbers, list.length(numbers) / 2)
    |> pair.second
    |> list.first()

  num
}

fn pages_ok(pages: List(Int), rules: List(#(Int, Int))) -> Bool {
  use page <- list.all(pages)
  let pages_after =
    list.drop_while(pages, fn(p) { p != page })
    |> list.drop(1)

  let forbidden_pages =
    list.filter(rules, fn(rule) { rule.1 == page })
    |> list.map(pair.first)

  list.all(pages_after, fn(page) { !list.contains(forbidden_pages, page) })
}

pub fn pt_1(input: Parsed) -> Int {
  let #(rules, pages_to_produce) = input
  use count, pages <- list.fold(pages_to_produce, 0)
  use <- bool.guard(!pages_ok(pages, rules), count)
  count + get_middle_num(pages)
}

fn reorder_pages(pages: List(Int), rules: List(#(Int, Int))) -> List(Int) {
  list.sort(pages, fn(num1, num2) {
    let num1_forbidden =
      list.filter(rules, fn(rule) { rule.1 == num1 })
      |> list.map(pair.first)

    case list.contains(num1_forbidden, num2) {
      True -> order.Gt
      False -> order.Lt
    }
  })
}

pub fn pt_2(input: Parsed) -> Int {
  let #(rules, pages_to_produce) = input
  use count, pages <- list.fold(pages_to_produce, 0)
  use <- bool.guard(pages_ok(pages, rules), count)
  reorder_pages(pages, rules)
  |> get_middle_num()
  |> int.add(count)
}
