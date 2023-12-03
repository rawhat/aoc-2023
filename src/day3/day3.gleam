import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/string
import simplifile

pub type Position {
  Position(row: Int, col: Int)
}

pub type Symbol {
  Symbol(start: Position, value: String)
}

pub type Number {
  Number(start: Position, value: String)
}

pub type Schematic {
  Schematic(symbols: List(Symbol), numbers: List(Number))
}

fn new_schematic() -> Schematic {
  Schematic([], [])
}

fn add_symbol(schematic: Schematic, at: Position, value: String) -> Schematic {
  Schematic(..schematic, symbols: [Symbol(at, value), ..schematic.symbols])
}

fn add_number(schematic: Schematic, at: Position, value: String) -> Schematic {
  Schematic(..schematic, numbers: [Number(at, value), ..schematic.numbers])
}

fn merge(left: Schematic, right: Schematic) -> Schematic {
  Schematic(
    numbers: list.append(left.numbers, right.numbers),
    symbols: list.append(left.symbols, right.symbols),
  )
}

fn parse_row(str: String, row: Int) -> Schematic {
  str
  |> string.to_graphemes
  |> list.index_fold(#(new_schematic(), "", None), fn(state, char, column) {
    let assert #(schematic, current_number, number_start) = state
    case char, current_number {
      ".", "" -> state
      ".", n -> {
        let assert Some(start) = number_start
        #(add_number(schematic, start, n), "", None)
      }
      "1", _
      | "2", _
      | "3", _
      | "4", _
      | "5", _
      | "6", _
      | "7", _
      | "8", _
      | "9", _
      | "0", _ -> {
        let start =
          option.or(number_start, Some(Position(row: row, col: column)))
        #(schematic, current_number <> char, start)
      }
      symbol, num -> {
        let with_number = case num {
          "" -> schematic
          value -> {
            let assert Some(start) = number_start
            add_number(schematic, start, value)
          }
        }
        #(add_symbol(with_number, Position(row, column), symbol), "", None)
      }
    }
  })
  |> fn(state) {
    let assert #(schematic, _current_number, _number_start) = state
    schematic
  }
}

fn parse_input() -> Schematic {
  let assert Ok(str) = simplifile.read("./src/day3/input.txt")
  let lines =
    str
    |> string.trim
    |> string.split("\n")
  use entries, line, row <- list.index_fold(lines, new_schematic())
  line
  |> parse_row(row)
  |> merge(entries)
}

fn position_range(entry: Number) -> List(Position) {
  let Position(row, col) = entry.start
  list.range(col, col + string.length(entry.value) - 1)
  |> list.map(fn(new_col) { Position(row, new_col) })
}

fn is_adjacent(number: Number, symbol: Symbol) -> Bool {
  let number_range = position_range(number)
  let pos2 = symbol.start

  list.any(number_range, fn(pos) {
    let row_diff = int.absolute_value(pos.row - pos2.row)
    let col_diff = int.absolute_value(pos.col - pos2.col)
    case row_diff, col_diff {
      0, 1 | 1, 0 | 1, 1 -> {
        True
      }
      _, _ -> False
    }
  })
}

fn find_part_numbers(schematic: Schematic) -> List(Int) {
  schematic.numbers
  |> list.filter(fn(number) {
    list.any(schematic.symbols, fn(symbol) { is_adjacent(number, symbol) })
  })
  |> list.map(fn(entry) {
    let assert Ok(num) = int.parse(entry.value)
    num
  })
}

fn find_gears(schematic: Schematic) -> Int {
  schematic.symbols
  |> list.filter(fn(symbol) { symbol.value == "*" })
  |> list.fold(0, fn(sum, symbol) {
    let adjacent_numbers =
      list.filter(schematic.numbers, fn(number) { is_adjacent(number, symbol) })
    case adjacent_numbers {
      [Number(_, left), Number(_, right)] -> {
        let assert Ok(left) = int.parse(left)
        let assert Ok(right) = int.parse(right)
        sum + { left * right }
      }
      _ -> sum
    }
  })
}

pub fn part_one() {
  parse_input()
  |> find_part_numbers
  |> int.sum
  |> fn(sum) {
    io.println("Sum of schematic part numbers: " <> int.to_string(sum))
  }
}

pub fn part_two() {
  parse_input()
  |> find_gears
  |> fn(sum) { io.println("Sum of gear ratios: " <> int.to_string(sum)) }
}
