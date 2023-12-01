import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

fn parse_input() -> List(String) {
  let assert Ok(str) =
    simplifile.read("./src/day1/input.txt")
    |> result.map(string.trim)
    |> result.map(string.split(_, "\n"))
  str
}

fn get_values(str: String, include_text: Bool, values: List(Int)) -> List(Int) {
  case str {
    "" -> list.reverse(values)
    "one" <> _rest if include_text == True ->
      get_values(string.drop_left(str, 1), include_text, [1, ..values])
    "two" <> _rest if include_text == True ->
      get_values(string.drop_left(str, 1), include_text, [2, ..values])
    "three" <> _rest if include_text == True ->
      get_values(string.drop_left(str, 1), include_text, [3, ..values])
    "four" <> _rest if include_text == True ->
      get_values(string.drop_left(str, 1), include_text, [4, ..values])
    "five" <> _rest if include_text == True ->
      get_values(string.drop_left(str, 1), include_text, [5, ..values])
    "six" <> _rest if include_text == True ->
      get_values(string.drop_left(str, 1), include_text, [6, ..values])
    "seven" <> _rest if include_text == True ->
      get_values(string.drop_left(str, 1), include_text, [7, ..values])
    "eight" <> _rest if include_text == True ->
      get_values(string.drop_left(str, 1), include_text, [8, ..values])
    "nine" <> _rest if include_text == True ->
      get_values(string.drop_left(str, 1), include_text, [9, ..values])
    _n -> {
      let assert Ok(#(next_grapheme, rest)) = string.pop_grapheme(str)
      case int.parse(next_grapheme) {
        Ok(value) -> get_values(rest, include_text, [value, ..values])
        _ -> get_values(rest, include_text, values)
      }
    }
  }
}

pub fn get_digit(line: String, include_text: Bool) -> Int {
  let values = get_values(line, include_text, [])
  let assert Ok(first) = list.first(values)
  let assert Ok(last) = list.last(values)

  { first * 10 } + last
}

fn solve(include_text: Bool) -> Int {
  parse_input()
  |> list.map(get_digit(_, include_text))
  |> list.fold(0, fn(a, b) { a + b })
}

pub fn part_one() {
  solve(False)
  |> fn(sum) { io.println("Part one: " <> int.to_string(sum)) }
}

pub fn part_two() {
  solve(True)
  |> fn(sum) { io.println("Part two: " <> int.to_string(sum)) }
}
